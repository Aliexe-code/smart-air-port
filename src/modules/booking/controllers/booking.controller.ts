import {
  Controller,
  Post,
  Body,
  UseGuards,
  HttpException,
  HttpStatus,
  Param,
  Req,
  BadRequestException,
  Logger,
  Get,
} from '@nestjs/common';
import { BookingService } from '../services/booking.service';
import { CreateBookingDto } from '../dto/create-booking.dto';
import { UserDocument } from '../../users/schemas/user.schema';
import { AuthGuard } from '@nestjs/passport';
import { BookingDocument } from '../schemas/booking.schema';
import { Request } from 'express';
import { GetUser } from 'src/common/decorators/user.decorator';
import { isMongoId } from 'class-validator';
import { instanceToPlain } from 'class-transformer';
import { EmailService } from '../../email/email.service';

@UseGuards(AuthGuard('jwt'))
@Controller('booking')
export class BookingController {
  private readonly logger = new Logger(BookingController.name);

  constructor(
    private readonly bookingService: BookingService,
    private readonly emailService: EmailService,
  ) {}

  @Post()
  async createBooking(
    @Body() createBookingDto: CreateBookingDto,
    @Req() req: Request,
  ): Promise<BookingDocument> {
    try {
      this.logger.log('Received createBooking request');
      this.logger.debug(`Request Body: ${JSON.stringify(createBookingDto)}`);

      if (!createBookingDto.idempotencyKey) {
        throw new BadRequestException('Idempotency key is required');
      }
      const user = req.user as UserDocument;
      if (!user) {
        throw new BadRequestException('User not found in request');
      }
      this.logger.debug(`User ID: ${user._id.toString()}`);
      if (!createBookingDto.flightId) {
        throw new BadRequestException('Flight ID is required');
      }
      if (!isMongoId(createBookingDto.flightId)) {
        throw new BadRequestException('Invalid flight ID format');
      }
      if (!createBookingDto.seats || createBookingDto.seats.length === 0) {
        throw new BadRequestException('At least one seat is required');
      }
      createBookingDto.seats.forEach((seat) => {
        if (!/^[A-Z]\d+$/.test(seat.seatNumber)) {
          throw new BadRequestException(
            `Invalid seat number format: ${seat.seatNumber}`,
          );
        }
      });
      if (!createBookingDto.paymentProvider) {
        throw new BadRequestException('Payment provider is required');
      }

      const booking = await this.bookingService.createBooking(
        user,
        createBookingDto,
        createBookingDto.idempotencyKey,
      );

      this.logger.log(`Booking created successfully: ${booking.id}`);

      // Send email notification to the user.
      const html = `
        <p>Dear ${user.firstName || 'User'},</p>
        <p>Your booking <strong>${booking.id}</strong> has been created and is pending confirmation.</p>
        <p>Thank you for choosing our service.</p>
      `;
      await this.emailService.sendImportantEmail(
        user.email,
        'Booking Created - Important Notification',
        html,
      );

      // Transform MongoDB document to plain object with string IDs instead of buffer objects
      const plainBooking = this.transformBookingToResponse(booking);
      return plainBooking;
    } catch (error: unknown) {
      this.logger.error(
        `Error creating booking: ${
          error instanceof Error ? error.message : 'Unknown error'
        }`,
      );

      if (error instanceof BadRequestException) {
        throw new HttpException(
          {
            success: false,
            message: error.message,
            error: 'Validation Failed',
            statusCode: 400,
          },
          HttpStatus.BAD_REQUEST,
        );
      } else if (error instanceof HttpException) {
        throw error;
      }
      throw new HttpException(
        'Internal error',
        HttpStatus.INTERNAL_SERVER_ERROR,
      );
    }
  }

  @Get(':id/status')
  async getBookingStatus(
    @Param('id') id: string,
  ): Promise<{ success: boolean; status: string }> {
    const status: string = await this.bookingService.getStatus(id);
    return { success: true, status };
  }

  @Post('confirm/:bookingId')
  async confirmBooking(
    @Param('bookingId') bookingId: string,
    @GetUser() user: UserDocument,
  ): Promise<BookingDocument> {
    const booking = await this.bookingService.confirmBooking(
      bookingId,
      user._id.toString(),
    );

    const html = `
      <p>Dear ${user.firstName || 'User'},</p>
      <p>Your booking <strong>${booking.id}</strong> has been confirmed.</p>
      <p>Thank you for choosing our service.</p>
    `;
    await this.emailService.sendImportantEmail(
      user.email,
      'Booking Confirmed - Important Notification',
      html,
    );

    return this.transformBookingToResponse(booking);
  }

  
  private transformBookingToResponse(booking: BookingDocument): BookingDocument {
    // First convert to a plain JavaScript object
    const plainBooking = booking.toObject ? booking.toObject() : booking;
    
    // Create a response object with proper string IDs
    const response = {
      ...plainBooking,
      _id: plainBooking._id.toString(),
      user: plainBooking.user.toString(),
      flight: plainBooking.flight.toString(),
      seats: plainBooking.seats.map(seat => ({
        ...seat,
        _id: seat._id.toString()
      }))
    };

    return response as BookingDocument;
  }
}