// src/common/interceptors/transform.interceptor.ts
import { Injectable, NestInterceptor, ExecutionContext, CallHandler } from '@nestjs/common';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';

@Injectable()
export class TransformInterceptor implements NestInterceptor {
  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    return next.handle().pipe(
      map(data => {
        // Skip wrapping if data is already a DTO-like object
        if (data && (typeof data === 'object') && ('success' in data || 'message' in data || 'firstName' in data)) {
          return data;
        }
        return { success: true, data };
      }),
    );
  }
}