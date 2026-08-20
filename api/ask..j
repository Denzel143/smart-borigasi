// File: api/ask.js

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method Not Allowed' });
  }

  const { plantName, langPrompt } = req.body;

  if (!plantName || !langPrompt) {
    return res.status(400).json({ error: 'Parameter plantName atau langPrompt tidak ditemukan.' });
  }

  try {
    // Mengambil API Key dari Vercel
    const apiKey = process.env.GEMINI_API_KEY;
    const url = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${apiKey}`;

    // Memanggil API Gemini
    const response = await fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        system_instruction: {
          parts: [{ text: langPrompt }]
        },
        contents: [
          {
            role: "user",
            parts: [{ text: plantName }]
          }
        ],
        generationConfig: {
          temperature: 0.1,
          response_mime_type: "application/json" // Memaksa output berupa JSON murni
        }
      })
    });

    const data = await response.json();

    if (!response.ok) {
      throw new Error(data.error?.message || `API Error: ${response.status}`);
    }

    // Ekstrak teks balasan dari struktur JSON Gemini
    const aiText = data.candidates[0].content.parts[0].text;

    // Kembalikan hasilnya ke frontend
    return res.status(200).json({ result: aiText });
  } catch (error) {
    console.error("Gemini API Error:", error);
    return res.status(500).json({ error: error.message });
  }
}
