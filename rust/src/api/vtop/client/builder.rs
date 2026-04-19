use crate::api::vtop::{
    session_manager::SessionManager, vtop_client::VtopClient, vtop_config::VtopConfig,
};

#[cfg(not(target_arch = "wasm32"))]
use reqwest::cookie::Jar;
use reqwest::{
    header::{HeaderMap, HeaderValue, USER_AGENT},
    Client,
};
use std::sync::Arc;

const VITAP_CUSTOM_CERT_PEM: &str = r#"-----BEGIN CERTIFICATE-----
MIIGTDCCBDSgAwIBAgIQOXpmzCdWNi4NqofKbqvjsTANBgkqhkiG9w0BAQwFADBf
MQswCQYDVQQGEwJHQjEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMTYwNAYDVQQD
Ey1TZWN0aWdvIFB1YmxpYyBTZXJ2ZXIgQXV0aGVudGljYXRpb24gUm9vdCBSNDYw
HhcNMjEwMzIyMDAwMDAwWhcNMzYwMzIxMjM1OTU5WjBgMQswCQYDVQQGEwJHQjEY
MBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMTcwNQYDVQQDEy5TZWN0aWdvIFB1Ymxp
YyBTZXJ2ZXIgQXV0aGVudGljYXRpb24gQ0EgRFYgUjM2MIIBojANBgkqhkiG9w0B
AQEFAAOCAY8AMIIBigKCAYEAljZf2HIz7+SPUPQCQObZYcrxLTHYdf1ZtMRe7Yeq
RPSwygz16qJ9cAWtWNTcuICc++p8Dct7zNGxCpqmEtqifO7NvuB5dEVexXn9RFFH
12Hm+NtPRQgXIFjx6MSJcNWuVO3XGE57L1mHlcQYj+g4hny90aFh2SCZCDEVkAja
EMMfYPKuCjHuuF+bzHFb/9gV8P9+ekcHENF2nR1efGWSKwnfG5RawlkaQDpRtZTm
M64TIsv/r7cyFO4nSjs1jLdXYdz5q3a4L0NoabZfbdxVb+CUEHfB0bpulZQtH1Rv
38e/lIdP7OTTIlZh6OYL6NhxP8So0/sht/4J9mqIGxRFc0/pC8suja+wcIUna0HB
pXKfXTKpzgis+zmXDL06ASJf5E4A2/m+Hp6b84sfPAwQ766rI65mh50S0Di9E3Pn
2WcaJc+PILsBmYpgtmgWTR9eV9otfKRUBfzHUHcVgarub/XluEpRlTtZudU5xbFN
xx/DgMrXLUAPaI60fZ6wA+PTAgMBAAGjggGBMIIBfTAfBgNVHSMEGDAWgBRWc1hk
lfmSGrASKgRieaFAFYghSTAdBgNVHQ4EFgQUaMASFhgOr872h6YyV6NGUV3LBycw
DgYDVR0PAQH/BAQDAgGGMBIGA1UdEwEB/wQIMAYBAf8CAQAwHQYDVR0lBBYwFAYI
KwYBBQUHAwEGCCsGAQUFBwMCMBsGA1UdIAQUMBIwBgYEVR0gADAIBgZngQwBAgEw
VAYDVR0fBE0wSzBJoEegRYZDaHR0cDovL2NybC5zZWN0aWdvLmNvbS9TZWN0aWdv
UHVibGljU2VydmVyQXV0aGVudGljYXRpb25Sb290UjQ2LmNybDCBhAYIKwYBBQUH
AQEEeDB2ME8GCCsGAQUFBzAChkNodHRwOi8vY3J0LnNlY3RpZ28uY29tL1NlY3Rp
Z29QdWJsaWNTZXJ2ZXJBdXRoZW50aWNhdGlvblJvb3RSNDYucDdjMCMGCCsGAQUF
BzABhhdodHRwOi8vb2NzcC5zZWN0aWdvLmNvbTANBgkqhkiG9w0BAQwFAAOCAgEA
YtOC9Fy+TqECFw40IospI92kLGgoSZGPOSQXMBqmsGWZUQ7rux7cj1du6d9rD6C8
ze1B2eQjkrGkIL/OF1s7vSmgYVafsRoZd/IHUrkoQvX8FZwUsmPu7amgBfaY3g+d
q1x0jNGKb6I6Bzdl6LgMD9qxp+3i7GQOnd9J8LFSietY6Z4jUBzVoOoz8iAU84OF
h2HhAuiPw1ai0VnY38RTI+8kepGWVfGxfBWzwH9uIjeooIeaosVFvE8cmYUB4TSH
5dUyD0jHct2+8ceKEtIoFU/FfHq/mDaVnvcDCZXtIgitdMFQdMZaVehmObyhRdDD
4NQCs0gaI9AAgFj4L9QtkARzhQLNyRf87Kln+YU0lgCGr9HLg3rGO8q+Y4ppLsOd
unQZ6ZxPNGIfOApbPVf5hCe58EZwiWdHIMn9lPP6+F404y8NNugbQixBber+x536
WrZhFZLjEkhp7fFXf9r32rNPfb74X/U90Bdy4lzp3+X1ukh1BuMxA/EEhDoTOS3l
7ABvc7BYSQubQ2490OcdkIzUh3ZwDrakMVrbaTxUM2p24N6dB+ns2zptWCva6jzW
r8IWKIMxzxLPv5Kt3ePKcUdvkBU/smqujSczTzzSjIoR5QqQA6lN1ZRSnuHIWCvh
JEltkYnTAH41QJ6SAWO66GrrUESwN/cgZzL4JLEqz1Y=
-----END CERTIFICATE-----"#;

impl VtopClient {
    /// Creates a new VtopClient instance with the provided configuration and credentials.
    ///
    /// This is the primary constructor for creating a `VtopClient`. It initializes the HTTP client
    /// with appropriate headers, cookie storage, and session management. The client is configured
    /// differently depending on the target platform (native vs WebAssembly).
    ///
    /// # Arguments
    ///
    /// * `config` - Configuration object containing VTOP server URL and user agent settings
    /// * `session` - Session manager for handling authentication state and CSRF tokens
    /// * `username` - The student's registration number or login ID
    /// * `password` - The student's password for VTOP authentication
    ///
    /// # Returns
    ///
    /// Returns a new `VtopClient` instance ready for authentication and API operations.
    ///
    /// # Platform-Specific Behavior
    ///
    /// ## Native (non-WebAssembly)
    /// - Configures persistent cookie storage using `reqwest::cookie::Jar`
    /// - Sets comprehensive HTTP headers for browser-like behavior
    /// - Includes security headers (Sec-Fetch-*)
    ///
    /// ## WebAssembly
    /// - Uses browser's built-in cookie handling
    /// - Configures minimal required headers
    /// - Relies on browser security policies
    ///
    /// # Examples
    ///
    /// ```
    /// use lib_vtop::{VtopClient, VtopConfig, SessionManager};
    ///
    /// let config = VtopConfig::default();
    /// let session = SessionManager::new();
    /// let client = VtopClient::with_config(
    ///     config,
    ///     session,
    ///     "21BCE1234".to_string(),
    ///     "mypassword".to_string()
    /// );
    ///
    /// // Now you can use the client for authentication
    /// // client.login().await?;
    /// ```
    ///
    /// # Notes
    ///
    /// - The client stores credentials internally for re-authentication if the session expires
    /// - Cookie storage is automatically managed on native platforms
    /// - User agent can be customized via `VtopConfig` to match specific browser profiles
    pub fn with_config(
        config: VtopConfig,
        session: SessionManager,
        username: String,
        password: String,
    ) -> Self {
        #[cfg(not(target_arch = "wasm32"))]
        {
            let client = Self::make_client(session.get_cookie_store(), &config.user_agent);
            Self {
                client,
                config,
                session,
                current_page: None,
                username,
                password,
                captcha_data: None,
            }
        }
        #[cfg(target_arch = "wasm32")]
        {
            let mut headers = HeaderMap::new();
            headers.insert(
                USER_AGENT,
                HeaderValue::from_str(&config.user_agent).unwrap_or_else(|_| {
                    HeaderValue::from_static("Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:140.0) Gecko/20100101 Firefox/140.0")
                }),
            );
            headers.insert(
                "Content-Type",
                HeaderValue::from_static("application/x-www-form-urlencoded"),
            );
            let client = reqwest::Client::builder()
                .default_headers(headers)
                .danger_accept_invalid_certs(true)
                .build()
                .unwrap();
            Self {
                client,
                config,
                session,
                current_page: None,
                username,
                password,
                captcha_data: None,
            }
        }
    }

    /// Creates and configures an HTTP client for native (non-WebAssembly) platforms.
    ///
    /// This internal helper method constructs a `reqwest::Client` with all necessary HTTP headers
    /// and cookie storage configured for interacting with the VTOP system. The client mimics
    /// browser behavior to ensure compatibility with VTOP's server-side expectations.
    ///
    /// # Arguments
    ///
    /// * `cookie_store` - Arc-wrapped cookie jar for persistent cookie storage across requests
    /// * `user_agent` - User-Agent string to identify the client to the server
    ///
    /// # Returns
    ///
    /// Returns a fully configured `reqwest::Client` with:
    /// - Custom user agent (falls back to Firefox if invalid)
    /// - Accept headers for HTML content
    /// - Content-Type for form submissions
    /// - Security headers (Sec-Fetch-*) for modern browser compatibility
    /// - Cookie persistence enabled
    /// - Priority hints for request scheduling
    ///
    /// # HTTP Headers Set
    ///
    /// - `User-Agent`: Custom or default Firefox user agent
    /// - `Accept`: HTML and XML content types
    /// - `Accept-Language`: English (US and general)
    /// - `Content-Type`: Form URL-encoded data
    /// - `Upgrade-Insecure-Requests`: Enables HTTPS upgrade
    /// - `Sec-Fetch-Dest`, `Sec-Fetch-Mode`, `Sec-Fetch-Site`, `Sec-Fetch-User`: Security policy headers
    /// - `Priority`: Request priority hints
    #[cfg(not(target_arch = "wasm32"))]
    fn make_client(cookie_store: Arc<Jar>, user_agent: &str) -> Client {
        use reqwest::Certificate;

        let mut headers = HeaderMap::new();

        headers.insert(
            USER_AGENT,
            HeaderValue::from_str(user_agent).unwrap_or_else(|_| {
                HeaderValue::from_static("Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:140.0) Gecko/20100101 Firefox/140.0")
            }),
        );
        headers.insert(
            "Accept",
            HeaderValue::from_static(
                "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
            ),
        );
        headers.insert(
            "Accept-Language",
            HeaderValue::from_static("en-US,en;q=0.5"),
        );
        headers.insert(
            "Content-Type",
            HeaderValue::from_static("application/x-www-form-urlencoded"),
        );
        headers.insert("Upgrade-Insecure-Requests", HeaderValue::from_static("1"));
        headers.insert("Sec-Fetch-Dest", HeaderValue::from_static("document"));
        headers.insert("Sec-Fetch-Mode", HeaderValue::from_static("navigate"));
        headers.insert("Sec-Fetch-Site", HeaderValue::from_static("same-origin"));
        headers.insert("Sec-Fetch-User", HeaderValue::from_static("?1"));
        headers.insert("Priority", HeaderValue::from_static("u=0, i"));

        let mut client_builder = reqwest::Client::builder()
            .default_headers(headers)
            .cookie_store(true)
            .cookie_provider(cookie_store);
        if let Ok(cert) = Certificate::from_pem(VITAP_CUSTOM_CERT_PEM.as_bytes()) {
            client_builder = client_builder.add_root_certificate(cert);
        }
        let client: Client = client_builder.build().unwrap();
        client
    }
}
