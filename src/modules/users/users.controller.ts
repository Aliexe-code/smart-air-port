import {
  Controller,
  Post,
  Body,
  Put,
  UseGuards,
  Get,
  Patch,
  UnauthorizedException,
} from '@nestjs/common';
import { UserManagementService } from './services/user-management.service';
import { AuthenticationService } from './services/authentication.service';
import { PasswordResetService } from './services/password.service';
import { CreateUserDto } from './dto/register-user.dto';
import { LoginUserDto } from './dto/login-user.dto';
import { ResetPasswordDto } from './dto/reset-password.dto';
import { ChangePasswordDto } from './dto/change-password.dto';
import { VerifyEmailDto } from './dto/verify-email.dto';
import { ResendEmailVerificationDto } from './dto/resend-email-verification.dto';
import { RefreshTokenDto } from './dto/refreshToken.dto';
import { RequestResetPasswordDto } from './dto/request-reset-password.dto';
import { UpdateUserRolesDto } from './dto/update-user-roles.dto';
import { RegisterResponseDto, UserResponseDto } from './dto/register-response.dto';
import { VerifyEmailResponseDto } from './dto/verifyEmail-response.dto';
import { ResendVerificationResponseDto } from './dto/resendVerificationResponse.dto';
import { RefreshTokenResponseDto } from './dto/refreshToken-response.dto';
import { LoginResponseDto } from './dto/login-response.dto';
import { ChangePasswordResponseDto } from './dto/changePassword-response.dto';
import { RequestResetPasswordResponseDto } from './dto/requestResetPassword-response.dto';
import { ResetPasswordResponseDto } from './dto/resetPassword-response.dto';
import { LogoutResponseDto } from './dto/logout-response.dto';
import { DashboardResponseDto } from './dto/dashboard-response.dto';
import { FlightManagementResponseDto } from './dto/flightManagement-response.dto';
import { UpdateRolesResponseDto } from './dto/updateRoles-response.dto';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
  ApiBody,
  ApiCreatedResponse,
} from '@nestjs/swagger';
import { UserDocument } from './schemas/user.schema';
import { GetUser } from '../../common/decorators/user.decorator';
import { Roles } from '../../common/decorators/roles.decorator';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Role } from '../../common/enums/role.enum';
import { ErrorResponseDto } from './dto/error-response.dto';
import { ProfileResponseDto } from './dto/profile-response.dto';
import { Public } from '../../common/decorators/public.decorator';

@ApiTags('users')
@Controller('users')
export class UsersController {
  constructor(
    private readonly authService: AuthenticationService,
    private readonly userManagementService: UserManagementService,
    private readonly passwordResetService: PasswordResetService,
  ) {}

  @ApiOperation({ summary: 'Get all users' })
  @ApiResponse({
    status: 200,
    description: 'Users retrieved successfully',
    type: [UserResponseDto],
  })
  @ApiResponse({
    status: 403,
    description: 'Forbidden - Only admins and moderators can access this resource',
    content: {
      'application/json': {
        schema: { $ref: '#/components/schemas/ErrorResponseDto' },
        examples: {
          forbidden: {
            summary: 'Insufficient permissions',
            value: {
              success: false,
              message: 'Only admins and moderators can access this resource',
              error: 'Forbidden',
              statusCode: 403,
              timestamp: '2025-02-27T09:05:47.193Z',
              path: '/users/all',
            },
          },
        },
      },
    },
  })
  @ApiResponse({
    status: 401,
    description: 'Unauthorized - Invalid credentials or unverified account',
    content: {
      'application/json': {
        schema: { $ref: '#/components/schemas/ErrorResponseDto' },
        examples: {
          unauthorizedCredentials: {
            summary: 'Invalid credentials',
            value: {
              success: false,
              message: 'Invalid user credentials',
              error: 'Unauthorized',
              statusCode: 401,
              timestamp: '2025-02-27T09:05:47.193Z',
              path: '/users/all',
            },
          },
          unverifiedAccount: {
            summary: 'Unverified account',
            value: {
              success: false,
              message: 'Verify your account please',
              error: 'Unauthorized',
              statusCode: 401,
              timestamp: '2025-02-27T09:05:47.193Z',
              path: '/users/all',
            },
          },
        },
      },
    },
  })
  @ApiBearerAuth()
  @UseGuards(RolesGuard)
  @Roles(Role.Admin, Role.Mod)
  @Get('all')
  async getAllUsers() {
    return this.userManagementService.getAllUsers();
  }

  @Public()
  @Post('register')
  @ApiOperation({ summary: 'Register a new user' })
  @ApiCreatedResponse({
    description: 'User registered successfully',
    type: RegisterResponseDto,
  })
  @ApiResponse({
    status: 400,
    description: 'Validation errors',
    content: {
      'application/json': {
        schema: { $ref: '#/components/schemas/ErrorResponseDto' },
        examples: {
          validationError: {
            summary: 'Invalid input',
            value: {
              success: false,
              message: 'Validation failed',
              error: 'Bad Request',
              statusCode: 400,
              timestamp: '2025-02-27T09:05:47.193Z',
              path: '/users/register',
              errors: { email: 'Invalid email format' },
            },
          },
        },
      },
    },
  })
  @ApiResponse({
    status: 409,
    description: 'Email already exists',
    content: {
      'application/json': {
        schema: { $ref: '#/components/schemas/ErrorResponseDto' },
        examples: {
          emailConflict: {
            summary: 'Email already in use',
            value: {
              success: false,
              message: 'Email already exists',
              error: 'Conflict',
              statusCode: 409,
              timestamp: '2025-02-27T09:05:47.193Z',
              path: '/users/register',
            },
          },
        },
      },
    },
  })
  @ApiBody({
    type: CreateUserDto,
    examples: {
      valid: {
        summary: 'Valid request',
        value: {
          email: 'user@example.com',
          password: 'User1@@User1',
          firstName: 'cse',
          lastName: 'zag',
        },
      },
      invalid: {
        summary: 'Invalid request',
        value: {
          email: 'invalid-email',
          password: 'weak',
          firstName: 'A',
          lastName: 'B',
        },
      },
    },
  })
  async register(@Body() createUserDto: CreateUserDto) {
    return this.userManagementService.register(createUserDto);
  }

  @Public()
  @ApiOperation({ summary: 'Verify user email' })
  @ApiResponse({
    status: 200,
    description: 'Email verified successfully',
    type: VerifyEmailResponseDto,
  })
  @ApiResponse({
    status: 400,
    description: 'Invalid or expired verification token',
    content: {
      'application/json': {
        schema: { $ref: '#/components/schemas/ErrorResponseDto' },
        examples: {
          invalidToken: {
            summary: 'Invalid token',
            value: {
              success: false,
              message: 'Invalid or expired verification token',
              error: 'Bad Request',
              statusCode: 400,
              timestamp: '2025-02-27T09:05:47.193Z',
              path: '/users/verify-email',
            },
          },
        },
      },
    },
  })
  @ApiBody({
    type: VerifyEmailDto,
    examples: {
      example1: { value: { verificationToken: 'verification-token' } },
    },
  })
  @Post('verify-email')
  async verifyEmail(@Body() verifyEmailDto: VerifyEmailDto) {
    return this.userManagementService.verifyEmail(verifyEmailDto.verificationToken);
  }

  @Public()
  @ApiOperation({ summary: 'Resend verification email' })
  @ApiResponse({
    status: 200,
    description: 'Verification email sent successfully',
    type: ResendVerificationResponseDto,
  })
  @ApiResponse({
    status: 404,
    description: 'Email not found',
    content: {
      'application/json': {
        schema: { $ref: '#/components/schemas/ErrorResponseDto' },
        examples: {
          notFound: {
            summary: 'Email not found',
            value: {
              success: false,
              message: 'Email not found',
              error: 'Not Found',
              statusCode: 404,
              timestamp: '2025-02-27T09:05:47.193Z',
              path: '/users/resend-verification',
            },
          },
        },
      },
    },
  })
  @ApiResponse({
    status: 400,
    description: 'Bad request - User already verified or email sending failed',
    content: {
      'application/json': {
        schema: { $ref: '#/components/schemas/ErrorResponseDto' },
        examples: {
          alreadyVerified: {
            summary: 'User already verified',
            value: {
              success: false,
              message: 'User is already verified',
              error: 'Bad Request',
              statusCode: 400,
              timestamp: '2025-02-27T09:05:47.193Z',
              path: '/users/resend-verification',
            },
          },
          emailFailure: {
            summary: 'Email sending failed',
            value: {
              success: false,
              message: 'Failed to send verification email',
              error: 'Bad Request',
              statusCode: 400,
              timestamp: '2025-02-27T09:05:47.193Z',
              path: '/users/resend-verification',
            },
          },
        },
      },
    },
  })
  @ApiBody({
    type: ResendEmailVerificationDto,
    examples: { example1: { value: { email: 'user@example.com' } } },
  })
  @Post('resend-verification')
  async resendVerificationEmail(@Body() resendEmailDto: ResendEmailVerificationDto) {
    return this.userManagementService.resendVerificationEmail(resendEmailDto.email);
  }

  @ApiOperation({ summary: 'Refresh JWT token' })
  @ApiResponse({
    status: 200,
    description: 'Token refreshed successfully',
    type: RefreshTokenResponseDto,
  })
  @ApiResponse({
    status: 401,
    description: 'Unauthorized - Invalid credentials, unverified account, or invalid/expired refresh token',
    content: {
      'application/json': {
        schema: { $ref: '#/components/schemas/ErrorResponseDto' },
        examples: {
          unauthorizedCredentials: {
            summary: 'Invalid credentials',
            value: {
              success: false,
              message: 'Invalid user credentials',
              error: 'Unauthorized',
              statusCode: 401,
              timestamp: '2025-02-27T09:05:47.193Z',
              path: '/users/refresh-token',
            },
          },
          unverifiedAccount: {
            summary: 'Unverified account',
            value: {
              success: false,
              message: 'Verify your account please',
              error: 'Unauthorized',
              statusCode: 401,
              timestamp: '2025-02-27T09:05:47.193Z',
              path: '/users/refresh-token',
            },
          },
          invalidToken: {
            summary: 'Invalid or expired refresh token',
            value: {
              success: false,
              message: 'Invalid or expired refresh token',
              error: 'Unauthorized',
              statusCode: 401,
              timestamp: '2025-02-27T09:05:47.193Z',
              path: '/users/refresh-token',
            },
          },
        },
      },
    },
  })
  @ApiBearerAuth()
  @ApiBody({
    type: RefreshTokenDto,
    examples: { example1: { value: { refreshToken: 'refresh-token' } } },
  })
  @Post('refresh-token')
  async refreshToken(@Body() refreshTokenDto: RefreshTokenDto) {
    return this.authService.refreshToken(refreshTokenDto.refreshToken);
  }

  @Public()
  @ApiOperation({ summary: 'Login user' })
  @ApiResponse({
    status: 200,
    description: 'User logged in successfully',
    type: LoginResponseDto,
  })
  @ApiResponse({
    status: 401,
    description: 'Unauthorized - Invalid credentials or email not verified',
    content: {
      'application/json': {
        schema: { $ref: '#/components/schemas/ErrorResponseDto' },
        examples: {
          invalidCredentials: {
            summary: 'Invalid credentials',
            value: {
              success: false,
              message: 'Invalid credentials',
              error: 'Unauthorized',
              statusCode: 401,
              timestamp: '2025-02-27T09:05:47.193Z',
              path: '/users/login',
            },
          },
          emailNotVerified: {
            summary: 'Email not verified',
            value: {
              success: false,
              message: 'Email not verified',
              error: 'Unauthorized',
              statusCode: 401,
              timestamp: '2025-02-27T09:05:47.193Z',
              path: '/users/login',
            },
          },
        },
      },
    },
  })
  @ApiBody({
    type: LoginUserDto,
    examples: {
      example1: { value: { email: 'user@example.com', password: 'Password123' } },
    },
  })
  @Post('login')
  async login(@Body() loginUserDto: LoginUserDto) {
    return this.authService.validateUser(loginUserDto);
  }

  @ApiOperation({ summary: 'Change user password' })
  @ApiResponse({
    status: 200,
    description: 'Password changed successfully',
    type: ChangePasswordResponseDto,
  })
  @ApiResponse({
    status: 401,
    description: 'Unauthorized - Invalid credentials, unverified account, or invalid old password',
    content: {
      'application/json': {
        schema: { $ref: '#/components/schemas/ErrorResponseDto' },
        examples: {
          unauthorizedCredentials: {
            summary: 'Invalid credentials',
            value: {
              success: false,
              message: 'Invalid user credentials',
              error: 'Unauthorized',
              statusCode: 401,
              timestamp: '2025-02-27T09:05:47.193Z',
              path: '/users/change-password',
            },
          },
          unverifiedAccount: {
            summary: 'Unverified account',
            value: {
              success: false,
              message: 'Verify your account please',
              error: 'Unauthorized',
              statusCode: 401,
              timestamp: '2025-02-27T09:05:47.193Z',
              path: '/users/change-password',
            },
          },
          invalidOldPassword: {
            summary: 'Invalid old password',
            value: {
              success: false,
              message: 'Invalid old password',
              error: 'Unauthorized',
              statusCode: 401,
              timestamp: '2025-02-27T09:05:47.193Z',
              path: '/users/change-password',
            },
          },
        },
      },
    },
  })
  @ApiResponse({
    status: 404,
    description: 'User not found',
    content: {
      'application/json': {
        schema: { $ref: '#/components/schemas/ErrorResponseDto' },
        examples: {
          notFound: {
            summary: 'User not found',
            value: {
              success: false,
              message: 'User not found',
              error: 'Not Found',
              statusCode: 404,
              timestamp: '2025-02-27T09:05:47.193Z',
              path: '/users/change-password',
            },
          },
        },
      },
    },
  })
  @ApiBearerAuth()
  @ApiBody({
    type: ChangePasswordDto,
    examples: {
      example1: { value: { oldPassword: 'OldPassword123', newPassword: 'NewPassword123' } },
    },
  })
  @Put('change-password')
  async changePassword(
    @GetUser() user: UserDocument,
    @Body() changePasswordDto: ChangePasswordDto,
  ) {
    if (!user) {
      throw new UnauthorizedException('User not found');
    }
    return this.passwordResetService.changePassword(user._id.toString(), changePasswordDto);
  }

  @Public()
  @ApiOperation({ summary: 'Request password reset' })
  @ApiResponse({
    status: 200,
    description: 'Password reset email sent',
    type: RequestResetPasswordResponseDto,
  })
  @ApiResponse({
    status: 404,
    description: 'Email not found',
    content: {
      'application/json': {
        schema: { $ref: '#/components/schemas/ErrorResponseDto' },
        examples: {
          notFound: {
            summary: 'Email not found',
            value: {
              success: false,
              message: 'Email not found',
              error: 'Not Found',
              statusCode: 404,
              timestamp: '2025-02-27T09:05:47.193Z',
              path: '/users/request-password-reset',
            },
          },
        },
      },
    },
  })
  @ApiResponse({
    status: 400,
    description: 'User not verified or email send failure',
    content: {
      'application/json': {
        schema: { $ref: '#/components/schemas/ErrorResponseDto' },
        examples: {
          notVerified: {
            summary: 'User not verified',
            value: {
              success: false,
              message: 'User must verify before password reset',
              error: 'Bad Request',
              statusCode: 400,
              timestamp: '2025-02-27T09:05:47.193Z',
              path: '/users/request-password-reset',
            },
          },
          emailFailure: {
            summary: 'Email send failure',
            value: {
              success: false,
              message: 'Failed to send password reset email',
              error: 'Bad Request',
              statusCode: 400,
              timestamp: '2025-02-27T09:05:47.193Z',
              path: '/users/request-password-reset',
            },
          },
        },
      },
    },
  })
  @ApiBody({
    type: RequestResetPasswordDto,
    examples: { example1: { value: { email: 'user@example.com' } } },
  })
  @Post('request-password-reset')
  async requestPasswordReset(@Body() requestPasswordResetDto: RequestResetPasswordDto) {
    return this.passwordResetService.requestPasswordReset(requestPasswordResetDto.email);
  }

  @Public()
  @ApiOperation({ summary: 'Reset password' })
  @ApiResponse({
    status: 200,
    description: 'Password reset successfully',
    type: ResetPasswordResponseDto,
  })
  @ApiResponse({
    status: 400,
    description: 'Invalid or expired reset token',
    content: {
      'application/json': {
        schema: { $ref: '#/components/schemas/ErrorResponseDto' },
        examples: {
          invalidToken: {
            summary: 'Invalid token',
            value: {
              success: false,
              message: 'Invalid or expired reset token',
              error: 'Bad Request',
              statusCode: 400,
              timestamp: '2025-02-27T09:05:47.193Z',
              path: '/users/reset-password',
            },
          },
        },
      },
    },
  })
  @ApiBody({
    type: ResetPasswordDto,
    examples: {
      example1: { value: { token: 'reset-token', newPassword: 'NewPassword123' } },
    },
  })
  @Post('reset-password')
  async resetPassword(@Body() resetPasswordDto: ResetPasswordDto) {
    return this.passwordResetService.resetPassword(resetPasswordDto);
  }

  @ApiOperation({ summary: 'Get user profile' })
  @ApiResponse({
    status: 200,
    description: 'User profile retrieved successfully',
    type: ProfileResponseDto,
  })
  @ApiResponse({
    status: 401,
    description: 'Unauthorized - Invalid credentials or unverified account',
    content: {
      'application/json': {
        schema: { $ref: '#/components/schemas/ErrorResponseDto' },
        examples: {
          unauthorizedCredentials: {
            summary: 'Invalid credentials',
            value: {
              success: false,
              message: 'Invalid user credentials',
              error: 'Unauthorized',
              statusCode: 401,
              timestamp: '2025-02-27T09:05:47.193Z',
              path: '/users/profile',
            },
          },
          unverifiedAccount: {
            summary: 'Unverified account',
            value: {
              success: false,
              message: 'Verify your account please',
              error: 'Unauthorized',
              statusCode: 401,
              timestamp: '2025-02-27T09:05:47.193Z',
              path: '/users/profile',
            },
          },
        },
      },
    },
  })
  @ApiResponse({
    status: 404,
    description: 'User not found',
    content: {
      'application/json': {
        schema: { $ref: '#/components/schemas/ErrorResponseDto' },
        examples: {
          notFound: {
            summary: 'User not found',
            value: {
              success: false,
              message: 'User not found',
              error: 'Not Found',
              statusCode: 404,
              timestamp: '2025-02-27T09:05:47.193Z',
              path: '/users/profile',
            },
          },
        },
      },
    },
  })
  @ApiBearerAuth()
  @Get('profile')
  async getProfile(@GetUser() user: UserDocument) {
    if (!user || !user._id) {
      throw new UnauthorizedException('Invalid user credentials');
    }
    return this.userManagementService.getProfile(user._id.toString());
  }

  @ApiOperation({ summary: 'Logout user' })
  @ApiResponse({
    status: 200,
    description: 'User logged out successfully',
    type: LogoutResponseDto,
  })
  @ApiResponse({
    status: 401,
    description: 'Unauthorized - Invalid credentials, unverified account, or invalid refresh token',
    content: {
      'application/json': {
        schema: { $ref: '#/components/schemas/ErrorResponseDto' },
        examples: {
          unauthorizedCredentials: {
            summary: 'Invalid credentials',
            value: {
              success: false,
              message: 'Invalid user credentials',
              error: 'Unauthorized',
              statusCode: 401,
              timestamp: '2025-02-27T09:05:47.193Z',
              path: '/users/logout',
            },
          },
          unverifiedAccount: {
            summary: 'Unverified account',
            value: {
              success: false,
              message: 'Verify your account please',
              error: 'Unauthorized',
              statusCode: 401,
              timestamp: '2025-02-27T09:05:47.193Z',
              path: '/users/logout',
            },
          },
          invalidToken: {
            summary: 'Invalid refresh token',
            value: {
              success: false,
              message: 'Invalid refresh token',
              error: 'Unauthorized',
              statusCode: 401,
              timestamp: '2025-02-27T09:05:47.193Z',
              path: '/users/logout',
            },
          },
        },
      },
    },
  })
  @ApiBearerAuth()
  @ApiBody({
    type: RefreshTokenDto,
    examples: { example1: { value: { refreshToken: 'refresh-token' } } },
  })
  @Post('logout')
  async logout(@GetUser() user: UserDocument, @Body('refreshToken') refreshToken: string) {
    if (!user || !user._id) {
      throw new UnauthorizedException('Invalid user credentials');
    }
    return this.userManagementService.logout(user._id.toString(), refreshToken);
  }

  @ApiOperation({ summary: 'Get admin dashboard' })
  @ApiResponse({
    status: 200,
    description: 'Admin-only content',
    type: DashboardResponseDto,
  })
  @ApiResponse({
    status: 403,
    description: 'Forbidden - Insufficient permissions',
    content: {
      'application/json': {
        schema: { $ref: '#/components/schemas/ErrorResponseDto' },
        examples: {
          forbidden: {
            summary: 'Insufficient permissions',
            value: {
              success: false,
              message: 'Insufficient permissions',
              error: 'Forbidden',
              statusCode: 403,
              timestamp: '2025-02-27T09:05:47.193Z',
              path: '/users/admin-dashboard',
            },
          },
        },
      },
    },
  })
  @ApiResponse({
    status: 401,
    description: 'Unauthorized - Invalid credentials or unverified account',
    content: {
      'application/json': {
        schema: { $ref: '#/components/schemas/ErrorResponseDto' },
        examples: {
          unauthorizedCredentials: {
            summary: 'Invalid credentials',
            value: {
              success: false,
              message: 'Unauthorized',
              error: 'Unauthorized',
              statusCode: 401,
              timestamp: '2025-02-27T09:05:47.193Z',
              path: '/users/admin-dashboard',
            },
          },
          unverifiedAccount: {
            summary: 'Unverified account',
            value: {
              success: false,
              message: 'Verify your account please',
              error: 'Unauthorized',
              statusCode: 401,
              timestamp: '2025-02-27T09:05:47.193Z',
              path: '/users/admin-dashboard',
            },
          },
        },
      },
    },
  })
  @ApiBearerAuth()
  @UseGuards(RolesGuard)
  @Roles(Role.Admin, Role.Mod)
  @Get('admin-dashboard')
  getAdminDashboard() {
    return { message: 'Admin-only content' };
  }

  @ApiOperation({ summary: 'Manage flights' })
  @ApiResponse({
    status: 200,
    description: 'Flight management dashboard',
    type: FlightManagementResponseDto,
  })
  @ApiResponse({
    status: 403,
    description: 'Forbidden - Insufficient permissions',
    content: {
      'application/json': {
        schema: { $ref: '#/components/schemas/ErrorResponseDto' },
        examples: {
          forbidden: {
            summary: 'Insufficient permissions',
            value: {
              success: false,
              message: 'Insufficient permissions',
              error: 'Forbidden',
              statusCode: 403,
              timestamp: '2025-02-27T09:05:47.193Z',
              path: '/users/flight-management',
            },
          },
        },
      },
    },
  })
  @ApiResponse({
    status: 401,
    description: 'Unauthorized - Invalid credentials or unverified account',
    content: {
      'application/json': {
        schema: { $ref: '#/components/schemas/ErrorResponseDto' },
        examples: {
          unauthorizedCredentials: {
            summary: 'Invalid credentials',
            value: {
              success: false,
              message: 'Unauthorized',
              error: 'Unauthorized',
              statusCode: 401,
              timestamp: '2025-02-27T09:05:47.193Z',
              path: '/users/flight-management',
            },
          },
          unverifiedAccount: {
            summary: 'Unverified account',
            value: {
              success: false,
              message: 'Verify your account please',
              error: 'Unauthorized',
              statusCode: 401,
              timestamp: '2025-02-27T09:05:47.193Z',
              path: '/users/flight-management',
            },
          },
        },
      },
    },
  })
  @ApiBearerAuth()
  @UseGuards(RolesGuard)
  @Roles(Role.Admin, Role.Mod)
  @Get('flight-management')
  manageFlights() {
    return { message: 'Flight management dashboard' };
  }

  @ApiOperation({ summary: 'Update user roles' })
  @ApiResponse({
    status: 200,
    description: 'User roles updated successfully',
    type: UpdateRolesResponseDto,
  })
  @ApiResponse({
    status: 403,
    description: 'Forbidden - Insufficient permissions',
    content: {
      'application/json': {
        schema: { $ref: '#/components/schemas/ErrorResponseDto' },
        examples: {
          forbidden: {
            summary: 'Insufficient permissions',
            value: {
              success: false,
              message: 'Insufficient permissions',
              error: 'Forbidden',
              statusCode: 403,
              timestamp: '2025-02-27T09:05:47.193Z',
              path: '/users/roles',
            },
          },
        },
      },
    },
  })
  @ApiResponse({
    status: 401,
    description: 'Unauthorized - Invalid credentials or unverified account',
    content: {
      'application/json': {
        schema: { $ref: '#/components/schemas/ErrorResponseDto' },
        examples: {
          unauthorizedCredentials: {
            summary: 'Invalid credentials',
            value: {
              success: false,
              message: 'Unauthorized',
              error: 'Unauthorized',
              statusCode: 401,
              timestamp: '2025-02-27T09:05:47.193Z',
              path: '/users/roles',
            },
          },
          unverifiedAccount: {
            summary: 'Unverified account',
            value: {
              success: false,
              message: 'Verify your account please',
              error: 'Unauthorized',
              statusCode: 401,
              timestamp: '2025-02-27T09:05:47.193Z',
              path: '/users/roles',
            },
          },
        },
      },
    },
  })
  @ApiResponse({
    status: 400,
    description: 'Bad request - Invalid roles or self-modification',
    content: {
      'application/json': {
        schema: { $ref: '#/components/schemas/ErrorResponseDto' },
        examples: {
          noRoles: {
            summary: 'No roles provided',
            value: {
              success: false,
              message: 'User must have at least one role',
              error: 'Bad Request',
              statusCode: 400,
              timestamp: '2025-02-27T09:05:47.193Z',
              path: '/users/roles',
            },
          },
          invalidRole: {
            summary: 'Invalid role',
            value: {
              success: false,
              message: 'Invalid role provided',
              error: 'Bad Request',
              statusCode: 400,
              timestamp: '2025-02-27T09:05:47.193Z',
              path: '/users/roles',
            },
          },
          selfModification: {
            summary: 'Self-modification attempt',
            value: {
              success: false,
              message: 'Admins cannot modify their own roles',
              error: 'Bad Request',
              statusCode: 400,
              timestamp: '2025-02-27T09:05:47.193Z',
              path: '/users/roles',
            },
          },
        },
      },
    },
  })
  @ApiBearerAuth()
  @UseGuards(RolesGuard)
  @Roles(Role.Admin)
  @ApiBody({
    type: UpdateUserRolesDto,
    examples: { example1: { value: { userId: 'user-id', roles: ['admin'] } } },
  })
  @Patch('roles')
  async updateRoles(
    @Body() updateUserRolesDto: UpdateUserRolesDto,
    @GetUser() currentUser: UserDocument,
  ) {
    if (!currentUser || !currentUser._id) {
      throw new UnauthorizedException('Unauthorized');
    }
    return this.authService.updateRoles(updateUserRolesDto.userId, updateUserRolesDto, currentUser);
  }
}