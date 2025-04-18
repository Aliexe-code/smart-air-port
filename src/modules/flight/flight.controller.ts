// src/modules/flight/flight.controller.ts
import { Controller, Get, Post, Query, Logger, HttpException, HttpStatus } from '@nestjs/common';
import { FlightService } from './flight.service';
import { QueryFlightDto } from './dto/query-flight.dto';
import { ApiTags } from '@nestjs/swagger';
import { ApiResponseDto } from './dto/api-response.dto';
import { Throttle } from '@nestjs/throttler';
import { plainToClass } from 'class-transformer';
import { FlightResponseDto } from './dto/flight-response.dto';
import { I18nService } from 'nestjs-i18n';

@ApiTags('Flights')
@Controller('flights')
export class FlightController {
  private readonly logger = new Logger(FlightController.name);

  constructor(private readonly flightService: FlightService,
    private readonly i18n: I18nService,
  ) {}

  @Get('search/available')
@Throttle({ default: { limit: 5, ttl: 60000 } })
async searchAvailableFlights(@Query() query: QueryFlightDto) {
  const page = query.page || 1;
  const limit = query.limit || 10;

  if (!Number.isInteger(page) || page < 1) {
    throw new HttpException('Page must be a positive integer', HttpStatus.BAD_REQUEST);
  }
  if (!Number.isInteger(limit) || limit < 1) {
    throw new HttpException('Limit must be a positive integer', HttpStatus.BAD_REQUEST);
  }

  const departureDate = new Date(query.departureDate);
  const currentDate = new Date();
  if (isNaN(departureDate.getTime())) {
    throw new HttpException('departureDate must be a valid date in YYYY-MM-DD format', HttpStatus.BAD_REQUEST);
  }

  const departureDateOnly = new Date(departureDate.getFullYear(), departureDate.getMonth(), departureDate.getDate());
  const currentDateOnly = new Date(currentDate.getFullYear(), currentDate.getMonth(), currentDate.getDate());
  if (departureDateOnly < currentDateOnly) {
    throw new HttpException('departureDate must be a future date', HttpStatus.BAD_REQUEST);
  }

  // Add passenger validation
  const { adults, children = 0, infants = 0, language = 'en' } = query;
  const totalPassengers = adults + children + infants;
  if (totalPassengers > 9) {
    throw new HttpException(
      await this.i18n.t('errors.tooManyPassengers', { lang: language, args: { max: 9 } }),
      HttpStatus.BAD_REQUEST,
    );
  }
  if (infants > adults) {
    throw new HttpException(
      await this.i18n.t('errors.tooManyInfants', { lang: language }),
      HttpStatus.BAD_REQUEST,
    );
  }

  const { paginatedFlights, total } = await this.flightService.searchAvailableFlights(query);

  const transformedFlights = paginatedFlights.map(flight =>
    plainToClass(FlightResponseDto, flight),
  );

  return new ApiResponseDto({
    success: true,
    message: `Found ${paginatedFlights.length} available flight offers (out of ${total} total)`,
    data: {
      flights: transformedFlights,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    },
  });
}

  /**
   * WARNING: Admin-only endpoint
   * Cleans up all seat holds - use with caution
   * This helps fix the 'Cast to ObjectId failed' errors
   */
  @Post('admin/cleanup-seat-holds')
  async cleanupAllSeatHolds() {
    try {
      this.logger.log('Running admin cleanup of all seat holds');
      const result = await this.flightService.cleanupAllSeatHolds();
      return new ApiResponseDto({
        success: true,
        message: `Successfully cleaned up ${result.count} seat holds`,
        data: result
      });
    } catch (error) {
      this.logger.error(`Failed to clean up seat holds: ${error.message}`);
      throw new HttpException(
        'Failed to clean up seat holds',
        HttpStatus.INTERNAL_SERVER_ERROR
      );
    }
  }
}