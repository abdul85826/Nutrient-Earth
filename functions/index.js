const functions = require("firebase-functions");
const fetch = require("node-fetch");

exports.aiInsight = functions.https.onRequest(async (req, res) => {
    try {
        const prompt = req.body.prompt;

        const response = await fetch("https://api.x.ai/v1/chat/completions", {
            method: "POST",
            headers: {
                "Authorization": "Bearer YOUR_XAI_KEY",
                "Content-Type": "application/json",
            },
            body: JSON.stringify({
                model: "grok-beta",
                messages: [
                    {
                        role: "system",
                        content: "You are a smart health and nutrition assistant. Give short, practical, modern advice.",
                    },
                    {
                        role: "user",
                        content: prompt,
                    },
                ],
            }),
        });

        const data = await response.json();

        res.json({
            insight: data.choices?.[0]?.message?.content || "No response",
        });

    } catch (error) {
        res.json({
            insight: "Error generating insight",
        });
    }
});