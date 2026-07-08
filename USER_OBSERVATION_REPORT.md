# User Observation Report

This report outlines the passive observations collected locally by the **User Observation Layer** and processed by the **User State Engine**. It focuses purely on raw observations of Identity, Environment, Behavior, and Daily States.

> [!NOTE]
> This engine does not make recommendations, diagnose conditions, or provide AI-driven explanations. It reports only what is verified and what remains missing.

---

## 1. Collected Data Schema

The passive observation layer is configured to collect the following metrics locally first:

### Identity
* **Age**: User's biological age (years)
* **Gender**: User's identified gender
* **Height**: Biological height (cm)
* **Weight**: Biological weight (kg)
* **City**: User's current location/city
* **Goal**: Primary health/wellness goal
* **Occupation**: Daily occupation (optional)

### Environment
* **Timezone**: System timezone
* **Weather**: Description of local weather conditions (e.g., Clear, Rain)
* **Temperature**: Outdoor ambient temperature (°C)
* **Humidity**: Ambient humidity percentage (%)
* **Air Quality**: Ambient air quality index (AQI)

### Behavior
* **Sleep Time**: Usual bed time
* **Wake Time**: Usual wake time
* **Activity Level**: Lifestyle activity level rating (e.g., Sedentary, Active)
* **Walking Steps**: Active daily step count
* **Hydration**: Daily water intake (liters)

### Daily State (Daily Check-In)
* **Energy**: Subjective energy level (1-10)
* **Stress**: Subjective stress level (1-10)
* **Mood**: Subjective mood level (1-10)
* **Sleep Quality**: Subjective sleep quality rating (1-10)

---

## 2. User State Analysis

Below is the state summary compiled by the **User State Engine**:

### What We Know About the User
* **Identity**: Fully populated upon onboarding completion.
* **Environment**: Passive location-based environment logging (timezone, weather, temperature, humidity, and AQI).
* **Behavior**: Local steps count from movement sensors and hydration logging.
* **Daily State**: Current check-in metrics for energy, stress, mood, and sleep quality.

### What We Don't Know / Missing Data
* **Wearable Integration**: None (explicitly disabled per requirements). All data is gathered via on-device sensors (pedometer) and manual check-ins.
* **Historical Behavior Trends**: Only current day records are stored in the local Isar database. Future cycles will build temporal profiles.

---

## 3. Database & Engine Status

* **Storage**: Local persistence is powered by **Isar database** (`IsarBiologicalState`) and Supabase local syncing.
* **State Engine**: Active on state mutations and runs on every lifecycle check-in or profile change.
