class AppConstants {
  // API Base URLs
  static const String baseUrl = 'https://api.letsholomoney.com';
  static const String smegarApiBaseUrl = 'https://api.btcsmega.co.bw';

  // API Endpoints
  static const String registerEndpoint = '/api/v1/users/register';
  static const String loginEndpoint = '/api/v1/auth/login';
  static const String loginWithSmegarEndpoint = '/api/v1/auth/login-smegar';
  static const String verifyKycEndpoint = '/api/v1/users/verify-kyc';
  static const String getUserEndpoint = '/api/v1/users';
  
  // Group Endpoints
  static const String createGroupEndpoint = '/api/v1/groups/create';
  static const String getGroupEndpoint = '/api/v1/groups';
  static const String joinGroupEndpoint = '/api/v1/groups/join';
  static const String getGroupsEndpoint = '/api/v1/groups/my-groups';
  static const String getGroupMembersEndpoint = '/api/v1/groups/{groupId}/members';
  
  // Transaction Endpoints
  static const String createTransactionEndpoint = '/api/v1/transactions/create';
  static const String getTransactionsEndpoint = '/api/v1/transactions';
  static const String getGroupTransactionsEndpoint = '/api/v1/transactions/group/{groupId}';
  
  // Wallet Endpoints
  static const String createWalletEndpoint = '/api/v1/wallets/create';
  static const String getWalletEndpoint = '/api/v1/wallets/{walletId}';
  static const String getWalletBalanceEndpoint = '/api/v1/wallets/{walletId}/balance';

  // Smegar Payment Gateway Endpoints
  static const String smegarInitiatePaymentEndpoint = '/pay/initiate';
  static const String smegarCheckPaymentStatusEndpoint = '/pay/status';
  static const String smegarRefundEndpoint = '/pay/refund';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Pagination
  static const int pageSize = 20;

  // Penalties
  static const double platformPenaltyPercentage = 0.30; // 30%
  static const double groupPenaltyPercentage = 0.70; // 70%

  // Subscription Prices
  static const Map<String, double> subscriptionPrices = {
    'tier1': 50.0,
    'tier2': 150.0,
    'tier3': 500.0,
  };

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'current_user';
  static const String refreshTokenKey = 'refresh_token';
}
