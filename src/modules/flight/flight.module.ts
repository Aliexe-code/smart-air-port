// src/modules/flight/flight.module.ts
import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { FlightService } from './flight.service';
import { FlightController } from './flight.controller';
import { FlightRepository } from './repositories/flight.repository';
import { FlightSchema } from './schemas/flight.schema';
import { FLIGHT_REPOSITORY } from './repositories/flight.repository.interface';
import { ConfigModule, ConfigService } from '@nestjs/config';
import Redis from 'ioredis';
import Redlock from 'redlock';

@Module({
  imports: [
    MongooseModule.forFeature([{ name: 'Flight', schema: FlightSchema }]),
    ConfigModule,
  ],
  controllers: [FlightController],
  providers: [
    FlightService,
    {
      provide: FLIGHT_REPOSITORY,
      useClass: FlightRepository,
    },
    {
      provide: 'REDIS_CLIENT',
      useFactory: (configService: ConfigService): Redis => {
        const host = configService.get<string>('REDIS_HOST', 'localhost');
        const port = configService.get<number>('REDIS_PORT', 6379);
        const password =
          configService.get<string>('REDIS_PASSWORD') || undefined;
        return new Redis({ host, port, ...(password ? { password } : {}) });
      },
      inject: [ConfigService],
    },
    {
      provide: 'REDLOCK',
      useFactory: (redisClient: Redis): Redlock => {
        return new Redlock([redisClient], {
          driftFactor: 0.01,
          retryCount: 10,
          retryDelay: 200,
          retryJitter: 200,
        });
      },
      inject: ['REDIS_CLIENT'],
    },
  ],
  exports: [FlightService],
})
export class FlightModule {}
