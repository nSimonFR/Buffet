--[[
    Special char must be escaped for:
    - ThousandSeparator
    - Patterns
--]]
if GetLocale() == "deDE" then
    ThousandSeparator = "%."

    KeyWords.Use = "Benutzen"
    KeyWords.Restores = "Stellt"
    KeyWords.Heals = "Heilt"
    KeyWords.ConjuredItem = "Herbeigezauberter Gegenstand"
    KeyWords.Health = "gesundheit"
    KeyWords.Damage = "schaden"
    KeyWords.Mana = "mana"
    KeyWords.WellFed = "essen verbringt"
    KeyWords.OverTime = "sec pro sekunde"

    Patterns.FlatHealth = "([%d%.]+) gesundheit"
    Patterns.FlatDamage = "([%d%.]+) schaden"
    Patterns.FlatMana = "([%d%.]+) mana"
    Patterns.PctHealth = "([%d%.]+)%% gesundheit"
    Patterns.PctMana = "([%d%.]+)%% mana"
    Patterns.OverTime = "von (%d+) sec"

    -- Classic stuff
    Classic_KeyWords.Bandage = "erste hilfe"

    Classic_Patterns.Bandage = "heilt ([%d%.]+) sek%. lang ([%d%.]+) punkt%(e%) schaden"

    Classic_Patterns.Food = "stellt im verlauf von ([%d%.]+) sek%. ([%d%.]+) punkt%(e%) gesundheit wieder her"
    Classic_Patterns.Drink = "stellt im verlauf von ([%d%.]+) sek%. ([%d%.]+) punkt%(e%) mana wieder her"

    Classic_Patterns.HealthPotion = "stellt ([%d%.]+) bis ([%d%.]+) punkt%(e%) gesundheit wieder her"
    Classic_Patterns.ManaPotion = "stellt ([%d%.]+) bis ([%d%.]+) punkt%(e%) mana wieder her"

    --ItemType.Consumable = "Verbrauchbares"
    --
    --ItemSubType.Bandage = "Verband"
    --ItemSubType.Consumable = "Verbrauchbares"
    --ItemSubType.FoodAndDrink = "Speis & Trank"
    --ItemSubType.Other = "Anderes"
    --ItemSubType.Potion = "Trank"
end