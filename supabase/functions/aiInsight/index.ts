import "jsr:@supabase/functions-js/edge-runtime.d.ts";

Deno.serve(async (req) => {
  const body = await req.json();

  const { sugar, bp, weight, problem } = body;

  let insight = "";
  let action = "";
  let product = "";

  if (sugar > 250) {
    insight = "Your sugar level is high and stressing your pancreas.";
    action = "Walk for 5 minutes immediately.";
    product = "Glucose Balance Mix";
  } else if (bp > 140) {
    insight = "Your blood pressure is elevated.";
    action = "Practice deep breathing for 3 minutes.";
    product = "Heart Calm Blend";
  } else {
    insight = "Your body is stable but needs consistency.";
    action = "Continue your daily runway.";
    product = "Energy Rise Elixir";
  }

  return new Response(
    JSON.stringify({ insight, action, product }),
    { headers: { "Content-Type": "application/json" } }
  );
});