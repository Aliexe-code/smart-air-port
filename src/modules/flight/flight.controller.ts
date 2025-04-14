import { Controller, Get, Query, UseGuards, Logger, HttpException, HttpStatus } from '@nestjs/common';
import { FlightService, FormattedFlight } from './flight.service';
import { QueryFlightDto } from './dto/query-flight.dto';
import { ApiTags, ApiOperation, ApiResponse, ApiQuery } from '@nestjs/swagger';
import { ApiResponseDto } from './dto/api-response.dto';
import { Throttle } from '@nestjs/throttler';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { Role } from '../../common/enums/role.enum';
import { plainToClass } from 'class-transformer';
import { FlightResponseDto } from './dto/flight-response.dto';

@ApiTags('Flights')
@Controller('flights')
export class FlightController {
  private readonly logger = new Logger(FlightController.name);

  constructor(private readonly flightService: FlightService) {}

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
    const currentDate = new Date('2025-04-13');
    if (isNaN(departureDate.getTime())) {
      throw new HttpException('departureDate must be a valid date in YYYY-MM-DD format', HttpStatus.BAD_REQUEST);
    }
    if (departureDate < currentDate) {
      throw new HttpException('departureDate must be a future date', HttpStatus.BAD_REQUEST);
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
}