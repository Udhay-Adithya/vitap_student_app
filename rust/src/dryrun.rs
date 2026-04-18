#![allow(dead_code)]
mod api;

use dotenv::dotenv;
use std::env;
use std::io::{self, Write};
use crate::api::vtop::vtop_errors::VtopError;

fn print_ascii_logo() {
    println!("\x1b[36m"); // Cyan color
    println!(
        r#"
╦ ╦╔╦╗╔═╗╔═╗  ╔═╗╦  ╦
║ ║ ║ ║ ║╠═╝  ║  ║  ║
╩═╝ ╩ ╚═╝╩    ╚═╝╩═╝╩

    ┌─────────────────────────────────────┐
    │        VTOP Client Terminal         │
    │       Interactive Test Suite        │
    └─────────────────────────────────────┘
    "#
    );
    println!("\x1b[0m"); // Reset color
}

fn print_welcome_message() {
    println!("\x1b[32m"); // Green color
    println!("🎓 Welcome to VTOP CLI - VIT-AP Student Portal Interface");
    println!("   Built with Rust | Version 1.0.3");
    println!("\x1b[0m"); // Reset color
}

fn print_menu() {
    println!("\x1b[33m"); // Yellow color
    println!("\n┌─ Available Options ─────────────────────────────────────┐");
    println!("│                                                         │");
    println!("│  1. 🔐 Login to VTOP                                   │");
    println!("│  2. 👤 Fetch Student Profile                           │");
    println!("│  3. 📅 Get Timetable                                   │");
    println!("│  4. 📊 View Attendance                                 │");
    println!("│  5. 📝 Check Marks                                     │");
    println!("│  6. 📋 Exam Schedule                                   │");
    println!("│  7. 🎯 Grade History                                   │");
    println!("│  8. 🏠 Submit General Outing                           │");
    println!("│  9. 🎉 Submit Weekend Outing                           │");
    println!("│  0. ❌ Exit                                            │");
    println!("│                                                        │");
    println!("└────────────────────────────────────────────────────────┘");
    println!("\x1b[0m"); // Reset color
}

fn get_user_input(prompt: &str) -> String {
    print!("\x1b[36m{}\x1b[0m", prompt); // Cyan prompt
    io::stdout().flush().unwrap();
    let mut input = String::new();
    io::stdin().read_line(&mut input).unwrap();
    input.trim().to_string()
}

fn print_separator() {
    println!("\x1b[35m{}\x1b[0m", "═".repeat(60)); // Magenta separator
}

fn print_success(message: &str) {
    println!("\x1b[32m✅ {}\x1b[0m", message); // Green success
}

fn print_error(message: &str) {
    println!("\x1b[31m❌ {}\x1b[0m", message); // Red error
}

fn print_info(message: &str) {
    println!("\x1b[34mℹ️  {}\x1b[0m", message); // Blue info
}

fn clear_screen() {
    print!("\x1b[2J\x1b[1;1H"); // Clear screen and move cursor to top
    io::stdout().flush().unwrap();
}

async fn handle_login(client: &mut api::vtop::vtop_client::VtopClient) -> bool {
    print_separator();
    println!("\x1b[33m🔐 Attempting VTOP Login...\x1b[0m");

    match api::vtop_get_client::vtop_client_login(client).await {
        Ok(_) => {
            print_success("VTOP login successful!");
            true
        }
        Err(VtopError::LoginOtpRequired) => {
            handle_login_otp(client).await
        }
        Err(e) => {
            print_error(&format!("VTOP login failed: {:?}", e));
            false
        }
    }
}

async fn handle_login_otp(client: &mut api::vtop::vtop_client::VtopClient) -> bool {
    print_separator();

    let mut otp_attempts = 0;

    let mut time_stamp = chrono::Local::now().timestamp() + 300;

    //The number of attempts is not limited by VTOP. This is only to prevent an infinite loop.
    while otp_attempts < 4 {
        otp_attempts += 1;
        let login_otp = get_user_input("Enter OTP sent to your email || NA to resend otp : ");
        
        if login_otp.trim().eq_ignore_ascii_case("NA") {

            if time_stamp > chrono::Local::now().timestamp() {
                print_error("Please wait before requesting a new OTP.");
                let wait_time = time_stamp - chrono::Local::now().timestamp();
                print_info(&format!("You can request a new OTP in {} seconds.", wait_time));
                otp_attempts -= 1;
                continue;
            }

            match api::vtop_get_client::handle_login_otp_resend(client).await {
                Ok(_) => {
                    print_success("OTP resent successfully! Please check your email.");
                    time_stamp = chrono::Local::now().timestamp() + 180;
                    otp_attempts = 0;
                    continue;
                }
                Err(e) => {
                    print_error(&format!("Failed to resend OTP: {:?}", e));
                    return false;
                }
            }
        } else if login_otp.trim().len() != 6 {
            print_error("OTP must be 6 characters long. Please try again.");
            otp_attempts -= 1;
            continue;
        } else {
            match api::vtop_get_client::handle_login_otp(client,login_otp).await{
                Ok(_) => {
                    print_success("VTOP login successful!");
                    return true;
                }
                Err(VtopError::LoginOtpIncorrect) => {
                    print_error("Incorrect OTP. Please try again.");
                    if otp_attempts == 4 {
                        print_error("Maximum OTP attempts reached. Login failed.");
                        return false;
                    } else {
                        print_info(&format!("Attempt {}/4", otp_attempts));
                        continue;
                    }
                }
                Err(VtopError::LoginOtpExpired) => {
                    otp_attempts -= 1; // Don't count expired OTP as an attempt
                    print_error("OTP has expired. Please request a new one.");
                    continue;
                }
                Err(e) => {
                    print_error(&format!("VTOP login failed: {:?}", e));
                    return false;
                }
            }
        }
    }
    false
}

async fn handle_student_profile(client: &mut api::vtop::vtop_client::VtopClient) {
    print_separator();
    println!("\x1b[33m👤 Fetching Student Profile...\x1b[0m");

    match api::vtop_get_client::fetch_student_profile(client).await {
        Ok(profile) => {
            print_success("Student profile retrieved successfully!");
            println!("\x1b[36m{}\x1b[0m", "─".repeat(40));
            println!("Profile Data (JSON):");
            println!("\x1b[37m{}\x1b[0m", profile);
        }
        Err(e) => print_error(&format!("Failed to fetch student profile: {:?}", e)),
    }
}

async fn handle_timetable(client: &mut api::vtop::vtop_client::VtopClient) {
    print_separator();
    println!("\x1b[33m📅 Fetching Timetable...\x1b[0m");

    // First get semesters
    match api::vtop_get_client::fetch_semesters(client).await {
        Ok(semesters) => {
            print_info(&format!("Available semesters: {:?}", semesters));
            let semester_id = get_user_input("Enter semester ID (or press Enter for default): ");
            let semester_id = if semester_id.is_empty() {
                "AP2024254".to_string()
            } else {
                semester_id
            };

            match api::vtop_get_client::fetch_timetable(client, semester_id).await {
                Ok(timetable) => {
                    print_success("Timetable retrieved successfully!");
                    println!("\x1b[37m{}\x1b[0m", timetable);
                }
                Err(e) => print_error(&format!("Failed to fetch timetable: {:?}", e)),
            }
        }
        Err(e) => print_error(&format!("Failed to fetch semesters: {:?}", e)),
    }
}

async fn handle_attendance(client: &mut api::vtop::vtop_client::VtopClient) {
    print_separator();
    println!("\x1b[33m📊 Fetching Attendance...\x1b[0m");

    let semester_id = get_user_input("Enter semester ID (or press Enter for default): ");
    let semester_id = if semester_id.is_empty() {
        "AP2024254".to_string()
    } else {
        semester_id
    };

    match api::vtop_get_client::fetch_attendance(client, semester_id).await {
        Ok(attendance) => {
            print_success("Attendance retrieved successfully!");
            println!("\x1b[37m{}\x1b[0m", attendance);
        }
        Err(e) => print_error(&format!("Failed to fetch attendance: {:?}", e)),
    }
}

async fn handle_marks(client: &mut api::vtop::vtop_client::VtopClient) {
    print_separator();
    println!("\x1b[33m📝 Fetching Marks...\x1b[0m");

    let semester_id = get_user_input("Enter semester ID (or press Enter for default): ");
    let semester_id = if semester_id.is_empty() {
        "AP2024254".to_string()
    } else {
        semester_id
    };

    match api::vtop_get_client::fetch_marks(client, semester_id).await {
        Ok(marks) => {
            print_success("Marks retrieved successfully!");
            println!("\x1b[37m{}\x1b[0m", marks);
        }
        Err(e) => print_error(&format!("Failed to fetch marks: {:?}", e)),
    }
}

async fn handle_exam_schedule(client: &mut api::vtop::vtop_client::VtopClient) {
    print_separator();
    println!("\x1b[33m📋 Fetching Exam Schedule...\x1b[0m");

    let semester_id = get_user_input("Enter semester ID (or press Enter for default): ");
    let semester_id = if semester_id.is_empty() {
        "AP2024254".to_string()
    } else {
        semester_id
    };

    match api::vtop_get_client::fetch_exam_shedule(client, semester_id).await {
        Ok(schedule) => {
            print_success("Exam schedule retrieved successfully!");
            println!("\x1b[37m{}\x1b[0m", schedule);
        }
        Err(e) => print_error(&format!("Failed to fetch exam schedule: {:?}", e)),
    }
}

async fn handle_grade_history(client: &mut api::vtop::vtop_client::VtopClient) {
    print_separator();
    println!("\x1b[33m🎯 Fetching Grade History...\x1b[0m");

    match api::vtop_get_client::fetch_grade_history(client).await {
        Ok(grades) => {
            print_success("Grade history retrieved successfully!");
            println!("\x1b[36m{}\x1b[0m", "─".repeat(40));
            println!("Grade History: {:?}", grades);
        }
        Err(e) => print_error(&format!("Failed to fetch grade history: {:?}", e)),
    }
}

async fn handle_general_outing(client: &mut api::vtop::vtop_client::VtopClient) {
    print_separator();
    println!("\x1b[33m🏠 Submit General Outing Form...\x1b[0m");

    let out_place = get_user_input("Enter destination/place to visit: ");
    let purpose_of_visit = get_user_input("Enter purpose of visit: ");
    let outing_date = get_user_input("Enter outing date (DD-MMM-YYYY, e.g., 15-Mar-2024): ");
    let out_time = get_user_input("Enter departure time (HH:MM, e.g., 14:00): ");
    let in_date = get_user_input("Enter return date (DD-MMM-YYYY, e.g., 15-Mar-2024): ");
    let in_time = get_user_input("Enter return time (HH:MM, e.g., 18:00): ");

    if out_place.is_empty()
        || purpose_of_visit.is_empty()
        || outing_date.is_empty()
        || out_time.is_empty()
        || in_date.is_empty()
        || in_time.is_empty()
    {
        print_error("All fields are required!");
        return;
    }

    match api::vtop_get_client::submit_general_outing_form(
        client,
        out_place,
        purpose_of_visit,
        outing_date,
        out_time,
        in_date,
        in_time,
    )
    .await
    {
        Ok(response) => {
            print_success("General outing form submitted successfully!");
            println!("\x1b[36m{}\x1b[0m", "─".repeat(40));
            println!("Server Response:");
            println!("\x1b[37m{}\x1b[0m", response);
        }
        Err(e) => print_error(&format!("Failed to submit general outing form: {:?}", e)),
    }
}

async fn handle_weekend_outing(client: &mut api::vtop::vtop_client::VtopClient) {
    print_separator();
    println!("\x1b[33m🎉 Submit Weekend Outing Form...\x1b[0m");

    let out_place = get_user_input("Enter destination/place to visit: ");
    let purpose_of_visit = get_user_input("Enter purpose of visit: ");
    let outing_date = get_user_input(
        "Enter outing date (DD-Mon-YY, e.g., 15-Dec-25 - must be Sunday or Monday): ",
    );

    println!("\x1b[36mAvailable time slots:\x1b[0m");
    println!("  1. 9:30 AM- 3:30PM");
    println!("  2. 10:30 AM- 4:30PM");
    println!("  3. 11:30 AM- 5:30PM");
    println!("  4. 12:30 PM- 6:30PM");
    let time_choice = get_user_input("Select time slot (1-4): ");
    let out_time = match time_choice.trim() {
        "1" => "9:30 AM- 3:30PM".to_string(),
        "2" => "10:30 AM- 4:30PM".to_string(),
        "3" => "11:30 AM- 5:30PM".to_string(),
        "4" => "12:30 PM- 6:30PM".to_string(),
        _ => {
            print_error("Invalid time slot selection!");
            return;
        }
    };

    let contact_number = get_user_input("Enter your contact number: ");

    if out_place.is_empty()
        || purpose_of_visit.is_empty()
        || outing_date.is_empty()
        || out_time.is_empty()
        || contact_number.is_empty()
    {
        print_error("All fields are required!");
        return;
    }

    match api::vtop_get_client::submit_weekend_outing_form(
        client,
        out_place,
        purpose_of_visit,
        outing_date,
        out_time,
        contact_number,
    )
    .await
    {
        Ok(response) => {
            print_success("Weekend outing form submitted successfully!");
            println!("\x1b[36m{}\x1b[0m", "─".repeat(40));
            println!("Server Response:");
            println!("\x1b[37m{}\x1b[0m", response);
        }
        Err(e) => print_error(&format!("Failed to submit weekend outing form: {:?}", e)),
    }
}

#[tokio::main]
async fn main() {
    // Load environment variables from .env file
    dotenv().ok();

    // Clear screen and show welcome
    clear_screen();
    print_ascii_logo();
    print_welcome_message();

    // Check for credentials
    let username = env::var("VTOP_USERNAME").unwrap_or_else(|_| {
        print_info("No VTOP_USERNAME found in environment.");
        get_user_input("Enter VTOP username: ")
    });

    let password = env::var("VTOP_PASSWORD").unwrap_or_else(|_| {
        print_info("No VTOP_PASSWORD found in environment.");
        get_user_input("Enter VTOP password: ")
    });

    if username.is_empty() || password.is_empty() {
        print_error("Username and password are required!");
        print_info("Set VTOP_USERNAME and VTOP_PASSWORD environment variables or enter them when prompted.");
        return;
    }

    print_info(&format!("Using credentials for user: {}", username));

    // Create VTOP client
    let mut client = api::vtop_get_client::get_vtop_client(username, password);
    let mut is_authenticated = false;

    // Main application loop
    loop {
        print_menu();
        let choice = get_user_input("\n🎯 Enter your choice (0-9): ");
        match choice.as_str() {
            "0" => {
                clear_screen();
                print_ascii_logo();
                println!("\x1b[32m🎓 Thank you for using VTOP CLI!\x1b[0m");
                println!("\x1b[36m   Goodbye! 👋\x1b[0m");
                break;
            }
            "1" => {
                is_authenticated = handle_login(&mut client).await;
            }
            "2" => {
                if !is_authenticated {
                    print_error("Please login first (option 1)");
                    continue;
                }
                handle_student_profile(&mut client).await;
            }
            "3" => {
                if !is_authenticated {
                    print_error("Please login first (option 1)");
                    continue;
                }
                handle_timetable(&mut client).await;
            }
            "4" => {
                if !is_authenticated {
                    print_error("Please login first (option 1)");
                    continue;
                }
                handle_attendance(&mut client).await;
            }
            "5" => {
                if !is_authenticated {
                    print_error("Please login first (option 1)");
                    continue;
                }
                handle_marks(&mut client).await;
            }
            "6" => {
                if !is_authenticated {
                    print_error("Please login first (option 1)");
                    continue;
                }
                handle_exam_schedule(&mut client).await;
            }
            "7" => {
                if !is_authenticated {
                    print_error("Please login first (option 1)");
                    continue;
                }
                handle_grade_history(&mut client).await;
            }
            "8" => {
                if !is_authenticated {
                    print_error("Please login first (option 1)");
                    continue;
                }
                handle_general_outing(&mut client).await;
            }
            "9" => {
                if !is_authenticated {
                    print_error("Please login first (option 1)");
                    continue;
                }
                handle_weekend_outing(&mut client).await;
            }
            _ => {
                print_error("Invalid choice! Please select a number between 0-9.");
            }
        }

        if choice != "0" {
            println!("\n\x1b[33mPress Enter to continue...\x1b[0m");
            let _ = get_user_input("");
        }
    }
}
