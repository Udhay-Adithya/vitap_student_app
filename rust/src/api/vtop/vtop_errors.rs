use flutter_rust_bridge::frb;
use serde::Serialize;

#[derive(Debug, Clone, Serialize)]
#[frb(non_opaque)]
pub enum VtopError {
    /// No internet connection or network unreachable
    NetworkError,
    /// Connection timed out while waiting for server response
    TimeoutError,
    /// SSL/TLS certificate validation failed
    SslError,
    /// DNS resolution failed - could not resolve server hostname
    DnsError,
    /// Connection was refused by the server
    ConnectionRefused,
    /// VTOP server returned an error or is unavailable
    VtopServerError,
    /// Authentication failed with optional message
    AuthenticationFailed(String),
    /// Could not parse registration number format
    RegistrationParsingError,
    /// Invalid username or password
    InvalidCredentials,
    /// Session has expired, need to re-authenticate
    SessionExpired,
    /// Failed to parse server response
    ParseError(String),
    /// App configuration error
    ConfigurationError(String),
    /// Captcha verification is required
    CaptchaRequired,
    /// Server returned unexpected response format
    InvalidResponse,
    /// Failed to read response body
    ResponseReadError,
    /// Digital Assignment file selection errors
    DigitalAssignmentFileNotFound,
    DigitalAssignmentFileTypeNotSupported,
    DigitalAssignmentFileSizeExceeded,
    DigitalAssignmentUploadOtpRequired,
    DigitalAssignmentUploadIncorrectOtp,
    /// Login otp verification required
    LoginOtpRequired,
    /// Login otp is incorrect
    LoginOtpIncorrect,
    ///Login otp expired
    LoginOtpExpired,
}

impl VtopError {
    /// Get a human-readable error message for display to users
    #[frb]
    pub fn message(&self) -> String {
        match self {
            VtopError::NetworkError => "No internet connection. Please check your network and try again.".to_string(),
            VtopError::TimeoutError => "Connection timed out. The server is taking too long to respond. Please try again.".to_string(),
            VtopError::SslError => "Secure connection failed. There may be an issue with the server's security certificate.".to_string(),
            VtopError::DnsError => "Could not reach the server. Please check your internet connection or try again later.".to_string(),
            VtopError::ConnectionRefused => "Unable to connect to VTOP server. The server may be down for maintenance.".to_string(),
            VtopError::VtopServerError => "VTOP server is temporarily unavailable. Please try again later.".to_string(),
            VtopError::AuthenticationFailed(msg) => {
                if msg.is_empty() {
                    "Login failed. Please check your credentials.".to_string()
                } else {
                    format!("Login failed: {}", msg)
                }
            },
            VtopError::RegistrationParsingError => "Invalid registration number format. Please check and try again.".to_string(),
            VtopError::InvalidCredentials => "Invalid username or password. Please try again.".to_string(),
            VtopError::SessionExpired => "Your session has expired. Please login again.".to_string(),
            VtopError::DigitalAssignmentFileNotFound => "Selected file is inaccessible or does not exist.".to_string(),
            VtopError::DigitalAssignmentFileTypeNotSupported => "File type should be pdf,xls,xlsx,doc,docx.".to_string(),
            VtopError::DigitalAssignmentFileSizeExceeded => "File size should not exceed 4 MB.".to_string(),
            VtopError::DigitalAssignmentUploadOtpRequired => "OTP verification is required for uploading the digital assignment. Please complete the OTP verification process.".to_string(),
            VtopError::DigitalAssignmentUploadIncorrectOtp => "Incorrect OTP entered. Please try again.".to_string(),
            VtopError::LoginOtpRequired => "OTP verification is required for login.".to_string(),
            VtopError::LoginOtpIncorrect => "Incorrect OTP entered for login. Please try again.".to_string(),
            VtopError::LoginOtpExpired => "OTP for login has expired. Please request a new OTP and try again.".to_string(),
            VtopError::ParseError(msg) => {
                if msg.is_empty() {
                    "Unable to process server response. Please try again.".to_string()
                } else {
                    format!("Data processing error: {}", msg)
                }
            },
            VtopError::ConfigurationError(msg) => {
                if msg.is_empty() {
                    "App configuration error. Please restart the app.".to_string()
                } else {
                    format!("Configuration error: {}", msg)
                }
            },
            VtopError::CaptchaRequired => "Please complete the captcha verification.".to_string(),
            VtopError::InvalidResponse => "Received unexpected response from server. Please try again.".to_string(),
            VtopError::ResponseReadError => "Failed to read server response. Please try again.".to_string(),
        }
    }

    /// Get the error type as a string for programmatic handling
    #[frb]
    pub fn error_type(&self) -> String {
        match self {
            VtopError::NetworkError => "NetworkError".to_string(),
            VtopError::TimeoutError => "TimeoutError".to_string(),
            VtopError::SslError => "SslError".to_string(),
            VtopError::DnsError => "DnsError".to_string(),
            VtopError::ConnectionRefused => "ConnectionRefused".to_string(),
            VtopError::VtopServerError => "VtopServerError".to_string(),
            VtopError::AuthenticationFailed(_) => "AuthenticationFailed".to_string(),
            VtopError::RegistrationParsingError => "RegistrationParsingError".to_string(),
            VtopError::InvalidCredentials => "InvalidCredentials".to_string(),
            VtopError::SessionExpired => "SessionExpired".to_string(),
            VtopError::ParseError(_) => "ParseError".to_string(),
            VtopError::ConfigurationError(_) => "ConfigurationError".to_string(),
            VtopError::CaptchaRequired => "CaptchaRequired".to_string(),
            VtopError::InvalidResponse => "InvalidResponse".to_string(),
            VtopError::ResponseReadError => "ResponseReadError".to_string(),
            VtopError::DigitalAssignmentFileNotFound => "FileNotFound".to_string(),
            VtopError::DigitalAssignmentFileTypeNotSupported => "FileTypeNotSupported".to_string(),
            VtopError::DigitalAssignmentFileSizeExceeded => "FileSizeExceeded".to_string(),
            VtopError::DigitalAssignmentUploadOtpRequired => {
                "DigitalAssignmentUploadOtpRequired".to_string()
            }
            VtopError::DigitalAssignmentUploadIncorrectOtp => {
                "DigitalAssignmentUploadIncorrectOtp".to_string()
            }
            VtopError::LoginOtpRequired => "LoginOtpRequired".to_string(),
            VtopError::LoginOtpIncorrect => "LoginOtpIncorrect".to_string(),
            VtopError::LoginOtpExpired => "LoginOtpExpired".to_string(),
        }
    }

    /// Get the raw error details for debugging (not for end users)
    #[frb]
    pub fn debug_message(&self) -> String {
        format!("{}", self)
    }
}

impl std::fmt::Display for VtopError {
    #[frb]
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            VtopError::NetworkError => write!(f, "Network connection error"),
            VtopError::TimeoutError => write!(f, "Connection timed out"),
            VtopError::SslError => write!(f, "SSL/TLS certificate error"),
            VtopError::DnsError => write!(f, "DNS resolution failed"),
            VtopError::ConnectionRefused => write!(f, "Connection refused by server"),
            VtopError::VtopServerError => write!(f, "VTOP server error"),
            VtopError::AuthenticationFailed(msg) => write!(f, "Authentication failed: {}", msg),
            VtopError::RegistrationParsingError => write!(f, "Failed to parse registration number"),
            VtopError::InvalidCredentials => write!(f, "Invalid username or password"),
            VtopError::SessionExpired => write!(f, "Session has expired"),
            VtopError::ParseError(msg) => write!(f, "Parse error: {}", msg),
            VtopError::ConfigurationError(msg) => write!(f, "Configuration error: {}", msg),
            VtopError::CaptchaRequired => write!(f, "Captcha verification required"),
            VtopError::InvalidResponse => write!(f, "Invalid response from server"),
            VtopError::ResponseReadError => write!(f, "Failed to read response body"),
            VtopError::DigitalAssignmentFileNotFound => write!(f, "File Selection Error"),
            VtopError::DigitalAssignmentFileTypeNotSupported => write!(f, "File Selection Error"),
            VtopError::DigitalAssignmentFileSizeExceeded => write!(f, "File Selection Error"),
            VtopError::DigitalAssignmentUploadOtpRequired => {
                write!(f, "Digital Assignment Upload OTP Required")
            }
            VtopError::DigitalAssignmentUploadIncorrectOtp => {
                write!(f, "Digital Assignment Upload Incorrect OTP")
            }
            VtopError::LoginOtpRequired => write!(f, "Login OTP Required"),
            VtopError::LoginOtpIncorrect => write!(f, "Login OTP Incorrect"),
            VtopError::LoginOtpExpired => write!(f, "Login OTP Expired"),
        }
    }
}

impl std::error::Error for VtopError {}

/// Maps a reqwest error to the appropriate VtopError variant
/// This provides more specific error messages based on the actual failure reason
#[frb(ignore)]
pub fn map_reqwest_error(err: reqwest::Error) -> VtopError {
    if err.is_timeout() {
        VtopError::TimeoutError
    } else if err.is_connect() {
        // Connection errors can have multiple causes
        let err_string = err.to_string().to_lowercase();
        if err_string.contains("dns")
            || err_string.contains("resolve")
            || err_string.contains("getaddrinfo")
        {
            VtopError::DnsError
        } else if err_string.contains("refused") {
            VtopError::ConnectionRefused
        } else if err_string.contains("ssl")
            || err_string.contains("tls")
            || err_string.contains("certificate")
        {
            VtopError::SslError
        } else {
            VtopError::NetworkError
        }
    } else if err.is_request() {
        // Request building errors
        let err_string = err.to_string().to_lowercase();
        if err_string.contains("ssl")
            || err_string.contains("tls")
            || err_string.contains("certificate")
        {
            VtopError::SslError
        } else {
            VtopError::NetworkError
        }
    } else if err.is_body() || err.is_decode() {
        VtopError::ResponseReadError
    } else if err.is_status() {
        // HTTP status code errors (4xx, 5xx)
        VtopError::VtopServerError
    } else {
        // Fallback for unknown errors
        VtopError::NetworkError
    }
}

/// Maps a reqwest error when reading response body
#[frb(ignore)]
pub fn map_response_read_error(_err: reqwest::Error) -> VtopError {
    VtopError::ResponseReadError
}

pub type VtopResult<T> = Result<T, VtopError>;
