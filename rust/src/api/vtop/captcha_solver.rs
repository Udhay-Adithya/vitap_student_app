use base64::Engine;
use image::DynamicImage;
use lazy_static::lazy_static;
use ndarray::{Array, Array1, Array2};
use serde::Deserialize;
use std::collections::HashMap;

use crate::api::vtop::vtop_client::{VtopError, VtopResult};

#[derive(Deserialize)]
struct Weights {
    weights: Vec<Vec<f64>>,
    biases: Vec<f64>,
}

lazy_static! {
    static ref BITMAPS: HashMap<char, Vec<Vec<u8>>> =
        serde_json::from_str(include_str!("./captcha/bitmaps.json")).unwrap();
    static ref WEIGHTS_DATA: Weights =
        serde_json::from_str(include_str!("./captcha/weights.json")).unwrap();
}

/// Solves the captcha from a base64 encoded image string.
pub async fn solve_captcha(captcha_data: &str) -> VtopResult<String> {
    let img = decode_base64_image(captcha_data)?;
    let pd = img.to_rgba8();
    let bls_data = saturation(&pd);

    let mut out = String::new();
    let label_txt = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";

    let weights: Array2<f64> = Array2::from_shape_vec(
        (WEIGHTS_DATA.weights.len(), WEIGHTS_DATA.weights[0].len()),
        WEIGHTS_DATA.weights.iter().flatten().cloned().collect(),
    )
    .unwrap();
    let biases: Array1<f64> = Array1::from_vec(WEIGHTS_DATA.biases.clone());

    for i in 0..6 {
        let x1 = (i + 1) * 25 + 2;
        let y1 = 7 + 5 * (i % 2) + 1;
        let x2 = (i + 2) * 25 + 1;
        let y2 = 35 - 5 * ((i + 1) % 2);

        let mut char_img = Vec::new();
        for row in &bls_data[y1..y2] {
            char_img.push(row[x1..x2].to_vec());
        }

        let bls_i = pre_img(&char_img);
        let flattened = flatten(&bls_i);
        let bls_i_2d = flattened
            .clone()
            .into_shape_with_order((1, flattened.len()))
            .unwrap();

        let mul_result = bls_i_2d.dot(&weights);
        let add_result = &mul_result + &biases;
        let softmax_result = max_soft(&add_result.row(0).to_owned());

        let mut max_prob = 0.0;
        let mut max_idx = 0;
        for (idx, &prob) in softmax_result.iter().enumerate() {
            if prob > max_prob {
                max_prob = prob;
                max_idx = idx;
            }
        }
        out.push(label_txt.chars().nth(max_idx).unwrap());
    }
    Ok(out)
}

// Helper function to decode a base64 string to a dynamic image
fn decode_base64_image(base64_str: &str) -> VtopResult<DynamicImage> {
    let b64_data = base64::engine::general_purpose::STANDARD
        .decode(base64_str.split(',').nth(1).unwrap_or(""))
        .map_err(|_| VtopError::ParseError("Invalid base64 data".into()))?;
    image::load_from_memory(&b64_data)
        .map_err(|_| VtopError::ParseError("Failed to decode image".into()))
}

// saturation function from captchaparser.js
fn saturation(d: &[u8]) -> Vec<Vec<u8>> {
    let mut saturate = Vec::with_capacity(d.len() / 4);
    for i in (0..d.len()).step_by(4) {
        let r = d[i] as f32;
        let g = d[i + 1] as f32;
        let b = d[i + 2] as f32;
        let max = r.max(g).max(b);
        let min = r.min(g).min(b);
        saturate.push(if max > 0.0 {
            ((max - min) * 255.0 / max) as u8
        } else {
            0
        });
    }

    let mut img = vec![vec![0; 200]; 40];
    for i in 0..40 {
        for j in 0..200 {
            img[i][j] = saturate[i * 200 + j];
        }
    }
    img
}

// pre_img function from captchaparser.js
fn pre_img(img: &[Vec<u8>]) -> Vec<Vec<u8>> {
    let mut avg = 0.0;
    for row in img {
        for &pixel in row {
            avg += pixel as f32;
        }
    }
    avg /= (img.len() * img[0].len()) as f32;

    let mut bits = vec![vec![0; img[0].len()]; img.len()];
    for i in 0..img.len() {
        for j in 0..img[0].len() {
            bits[i][j] = if img[i][j] as f32 > avg { 1 } else { 0 };
        }
    }
    bits
}

// flatten function from captchaparser.js
fn flatten(arr: &[Vec<u8>]) -> Array1<f64> {
    let mut bits = Vec::with_capacity(arr.len() * arr[0].len());
    for row in arr {
        for &bit in row {
            bits.push(bit as f64);
        }
    }
    Array::from(bits)
}

// max_soft function from captchaparser.js
fn max_soft(a: &Array1<f64>) -> Array1<f64> {
    let max_val = a.iter().fold(f64::NEG_INFINITY, |a, &b| a.max(b));
    let exp_a: Array1<f64> = a.mapv(|x| (x - max_val).exp());
    let sum_exp_a = exp_a.sum();
    exp_a / sum_exp_a
}
