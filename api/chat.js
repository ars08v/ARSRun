export default async function handler(req, res) {
    if (req.method !== 'POST') {
        return res.status(405).json({ message: 'Method not allowed' });
    }

    try {
        const { message } = req.body;

        const response = await fetch("https://api.groq.com/openai/v1/chat/completions", {
            method: "POST",
            headers: {
                "Authorization": `Bearer ${process.env.GROQ_API_KEY}`,
                "Content-Type": "application/json"
            },
            body: JSON.stringify({
                model: "llama3-70b-8192",
                messages: [
                    { role: "system", content: "أنت ARS، مساعد ذكي خبير في البرمجة، Python، Termux، JS، والتقنية. أجب بكل احترافية." },
                    { role: "user", content: message }
                ]
            })
        });

        const data = await response.json();

        // التأكد من أننا تلقينا رداً صالحاً من Groq
        if (!response.ok) {
            throw new Error(data.error?.message || "Failed to fetch from Groq");
        }

        res.status(200).json(data);
    } catch (error) {
        console.error("API Error:", error);
        res.status(500).json({ error: error.message });
    }
}

