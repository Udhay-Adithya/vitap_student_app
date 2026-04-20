//! # faculty_fetch binary
//!
//! A standalone development utility for scraping the complete VIT-AP faculty
//! list from VTOP and saving it as a JSON file.
//!
//! ## What it does
//! 1. Authenticates against VTOP using credentials from the `.env` file
//!    (or prompts interactively if they are missing).
//! 2. Issues a single POST to `/vtop/hrms/EmployeeSearchForStudent` with
//!    `empId=` (empty string, which VTOP interprets as "return all") to
//!    retrieve every faculty member in one HTTP round-trip.
//! 3. Parses the HTML response into a `Vec<GetFaculty>` containing each
//!    member's name, designation, school / centre, and employee ID.
//! 4. Serialises the list to pretty-printed JSON and writes it to
//!    `faculty_list.json` in the current working directory.
//! 5. Prints a brief preview of the first three entries to stdout.
//!
//! ## Usage
//! ```sh
//! # From the rust/ directory:
//! cargo run --bin faculty_fetch
//! ```
//!
//! The resulting `faculty_list.json` is intended to be bundled with the
//! Flutter app (e.g. in `assets/`) so that the faculty list screen can be
//! populated instantly without a network request. Detailed per-faculty
//! information (email, cabin, office hours) is fetched on-demand when the
//! user taps a name, using the `fetch_all_faculty` FRB function and
//! `fetchFacultyData` respectively.
//!
//! ## Environment
//! Reads `VTOP_USERNAME` and `VTOP_PASSWORD` from `.env` (see `.env.example`).
//! If the OTP flow is triggered, the binary prompts for the one-time code
//! via stdin.

//! # faculty_fetch binary
//!
//! A standalone development utility for scraping the complete VIT-AP faculty
//! list from VTOP and saving it as a JSON file.
//!
//! ## What it does
//! 1. Authenticates against VTOP using credentials from the `.env` file
//!    (or prompts interactively if they are missing).
//! 2. Issues a single POST to `/vtop/hrms/EmployeeSearchForStudent` with
//!    `empId=` (empty string, which VTOP interprets as "return all") to
//!    retrieve every faculty member in one HTTP round-trip.
//! 3. Parses the HTML response into a `Vec<GetFaculty>` containing each
//!    member's name, designation, school / centre, and employee ID.
//! 4. Serialises the list to pretty-printed JSON and writes it to
//!    `faculty_list.json` in the current working directory.
//! 5. Prints a brief preview of the first three entries to stdout.
//!
//! ## Usage
//! ```sh
//! # From the rust/ directory:
//! cargo run --bin faculty_fetch
//! ```
//!
//! The resulting `faculty_list.json` is intended to be bundled with the
//! Flutter app (e.g. in `assets/`) so that the faculty list screen can be
//! populated instantly without a network request. Detailed per-faculty
//! information (email, cabin, office hours) is fetched on-demand when the
//! user taps a name, using the `fetch_all_faculty` FRB function and
//! `fetchFacultyData` respectively.
//!
//! ## Environment
//! Reads `VTOP_USERNAME` and `VTOP_PASSWORD` from `.env` (see `.env.example`).
//! If the OTP flow is triggered, the binary prompts for the one-time code
//! via stdin.

#![allow(dead_code)]
mod api;

use crate::api::vtop::vtop_errors::VtopError;
use dotenv::dotenv;
use std::env;
use std::io::{self, Write};

fn get_user_input(prompt: &str) -> String {
    print!("\x1b[36m{}\x1b[0m", prompt);
    io::stdout().flush().unwrap();
    let mut input = String::new();
    io::stdin().read_line(&mut input).unwrap();
    input.trim().to_string()
}

/// Log in, handling the OTP flow if VTOP requires it.
async fn login(client: &mut api::vtop::vtop_client::VtopClient) -> bool {
    println!("\x1b[33m🔐 Logging in to VTOP...\x1b[0m");
    match api::vtop_get_client::vtop_client_login(client).await {
        Ok(_) => {
            println!("\x1b[32m✅ Login successful!\x1b[0m");
            true
        }
        Err(VtopError::LoginOtpRequired) => {
            println!("\x1b[33m🔑 OTP required. Check your registered email.\x1b[0m");
            let otp = get_user_input("Enter 6-digit OTP: ");
            match api::vtop_get_client::handle_login_otp(client, otp).await {
                Ok(_) => {
                    println!("\x1b[32m✅ OTP accepted. Login successful!\x1b[0m");
                    true
                }
                Err(e) => {
                    eprintln!("\x1b[31m❌ OTP login failed: {:?}\x1b[0m", e);
                    false
                }
            }
        }
        Err(e) => {
            eprintln!("\x1b[31m❌ Login failed: {:?}\x1b[0m", e);
            false
        }
    }
}

#[tokio::main]
async fn main() {
    dotenv().ok();

    let username =
        env::var("VTOP_USERNAME").unwrap_or_else(|_| get_user_input("Enter VTOP username: "));
    let password =
        env::var("VTOP_PASSWORD").unwrap_or_else(|_| get_user_input("Enter VTOP password: "));

    if username.is_empty() || password.is_empty() {
        eprintln!("\x1b[31m❌ Username and password are required.\x1b[0m");
        return;
    }

    let mut client = api::vtop_get_client::get_vtop_client(username, password);

    if !login(&mut client).await {
        return;
    }

    // Fetch every faculty member in one request (empId=*)
    println!("\n\x1b[33m📋 Fetching all faculty from VTOP (empId=*)...\x1b[0m");
    let faculty_list = match client.get_all_faculty().await {
        Ok(list) => list,
        Err(e) => {
            eprintln!("\x1b[31m❌ Failed to fetch faculty list: {:?}\x1b[0m", e);
            return;
        }
    };

    println!(
        "\x1b[32m✅ Fetched {} faculty members.\x1b[0m",
        faculty_list.len()
    );

    // Serialise to pretty JSON and write to file
    let json = match serde_json::to_string_pretty(&faculty_list) {
        Ok(j) => j,
        Err(e) => {
            eprintln!("\x1b[31m❌ Serialisation error: {:?}\x1b[0m", e);
            return;
        }
    };

    let output_path = "faculty_list.json";
    match std::fs::write(output_path, &json) {
        Ok(_) => println!(
            "\x1b[32m✅ Saved to {output_path} ({} bytes)\x1b[0m",
            json.len()
        ),
        Err(e) => eprintln!("\x1b[31m❌ Failed to write file: {:?}\x1b[0m", e),
    }

    // Print first 3 entries as a preview
    println!("\n\x1b[36m─── Preview (first 3) ───\x1b[0m");
    for entry in faculty_list.iter().take(3) {
        println!(
            "  {} | {} | {} | emp_id: {}",
            entry.faculty_name, entry.designation, entry.school_or_centre, entry.emp_id
        );
    }
}
