import {
  Injectable,
  NotFoundException,
  ConflictException,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Flight } from '../schemas/flight.schema';
import { IFlightRepository } from './flight.repository.interface';
import { CreateFlightDto } from '../dto/create-flight.dto';
import { UpdateFlightDto } from '../dto/update-flight.dto';
import { QueryFlightDto } from '../dto/query-flight.dto';
import { FlightAvailabilityQuery } from '../dto/available-flight-query.dto';
import { FlightQueryFilter } from '../dto/query-flight.dto';
import { FlightUpdateSeatsParams } from '../dto/flight-update-seats.dto';

@Injectable()
export class FlightRepository implements IFlightRepository {
  constructor(
    @InjectModel('Flight') private readonly flightModel: Model<Flight>,
  ) {}

  async create(createFlightDto: CreateFlightDto): Promise<Flight> {
    const newFlight = new this.flightModel(createFlightDto);
    return newFlight.save();
  }

  async findAll(): Promise<Flight[]> {
    return this.flightModel.find().exec();
  }

  async searchFlights(query: QueryFlightDto & { skip?: number; limit?: number }): Promise<Flight[]> {
    const filter: FlightQueryFilter = {};
    if (query.departureAirport) filter.departureAirport = query.departureAirport;
    if (query.arrivalAirport) filter.arrivalAirport = query.arrivalAirport;
    if (query.departureDate) {
      const date = new Date(query.departureDate);
      const startOfDay = new Date(date);
      startOfDay.setHours(0, 0, 0, 0);
      const endOfDay = new Date(date);
      endOfDay.setHours(23, 59, 59, 999);
      filter.departureTime = { $gte: startOfDay, $lte: endOfDay };
    }
    const { skip = 0, limit = 10 } = query;
    return this.flightModel.find(filter).skip(skip).limit(limit).exec();
  }

  async searchAvailableFlights(
    query: FlightAvailabilityQuery,
  ): Promise<Flight[]> {
    return this.flightModel.find(query).exec();
  }

  async findById(id: string): Promise<Flight | null> {
    return this.flightModel.findById(id).exec();
  }

  async findOneAndUpdate(
    filter: { _id: string; version: number },
    update: UpdateFlightDto,
  ): Promise<Flight | null> {
    return this.flightModel.findOneAndUpdate(filter, update, { new: true });
  }

  async findByFlightNumber(flightNumber: string): Promise<Flight | null> {
    return this.flightModel.findOne({ flightNumber }).exec();
  }

  async updateSeats(params: FlightUpdateSeatsParams): Promise<Flight | null> {
    const updatedFlight = await this.flightModel.findOneAndUpdate(
      {
        _id: params.flightId,
        version: params.expectedVersion, // Now valid with updated interface
      },
      {
        $inc: { seatsAvailable: params.seatDelta, version: 1 },
      },
      {
        new: true,
      },
    );

    if (!updatedFlight) {
      throw new ConflictException('Seat inventory changed, please refresh');
    }
    return updatedFlight;
  }

  async update(id: string, updateFlightDto: UpdateFlightDto): Promise<Flight> {
    const existingFlight = await this.flightModel.findById(id).lean();
    if (!existingFlight) {
      throw new NotFoundException('Flight not found');
    }

    const updatedFlight = await this.flightModel
      .findByIdAndUpdate(
        id,
        { ...updateFlightDto, updatedAt: new Date() },
        { new: true, lean: true },
      )
      .exec();

    if (!updatedFlight) {
      throw new NotFoundException('Flight not found after update');
    }
    return updatedFlight;
  }

  async delete(id: string): Promise<Flight> {
    const flight = await this.flightModel.findByIdAndDelete(id).exec();
    if (!flight) {
      throw new NotFoundException(`Flight with id ${id} not found`);
    }
    return flight;
  }

  async countFlights(query: QueryFlightDto): Promise<number> {
    const filter: FlightQueryFilter = {};
    if (query.departureAirport) {
      filter.departureAirport = query.departureAirport;
    }
    if (query.arrivalAirport) {
      filter.arrivalAirport = query.arrivalAirport;
    }
    if (query.departureDate) {
      const date = new Date(query.departureDate);
      const startOfDay = new Date(date);
      startOfDay.setHours(0, 0, 0, 0);
      const endOfDay = new Date(date);
      endOfDay.setHours(23, 59, 59, 999);
      filter.departureTime = {
        $gte: startOfDay,
        $lte: endOfDay,
      };
    }
    return this.flightModel.countDocuments(filter).exec();
  }
}