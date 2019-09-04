--[[
    Special char must be escaped for:
    - ThousandSeparator
    - Patterns
--]]
if GetLocale() == "frFR" then
    ThousandSeparator = ""

    KeyWords.Use = "Utiliser"
    KeyWords.Restores = "Rend"
    KeyWords.Heals = "Rend"
    KeyWords.ConjuredItem = "Objet invoqué"
    KeyWords.Health = "vie"
    KeyWords.Damage = "vie"
    KeyWords.Mana = "mana"
    KeyWords.WellFed = "bien nourri"
    KeyWords.OverTime = "par second pendant"

    Patterns.FlatHealth = "([%d%.]+).-vie" -- il peut y avoir du text entre la valeur numéric et le mot "vie"
    Patterns.FlatDamage = "([%d%.]+).-vie"
    Patterns.FlatMana = "([%d%.]+).-mana"
    Patterns.PctHealth = "([%d%.]+)%%.-vie"
    Patterns.PctMana = "([%d%.]+)%%.-mana"
    Patterns.OverTime = "pendant (%d+) s%."


    -- Classic stuff
    Classic_KeyWords.Bandage = "secourisme"

    Classic_Patterns.Bandage = "rend ([%d%.]+) points de vie en ([%d%.]+) sec"

    Classic_Patterns.Food = "rend ([%d%.]+) points de vie en ([%d%.]+) sec"
    Classic_Patterns.Drink = "rend ([%d%.]+) points de mana en ([%d%.]+) sec"

    Classic_Patterns.HealthPotion = "([%d%.]+) à ([%d%.]+) points de vie"
    Classic_Patterns.ManaPotion = "([%d%.]+) à ([%d%.]+) points de mana"

    --ItemType.Consumable = "Consommable"
    --
    --ItemSubType.Bandage = "Bandage"
    --ItemSubType.Consumable = "Consommable"
    --ItemSubType.FoodAndDrink = "Nourriture et boissons"
    --ItemSubType.Other = "Autre"
    --ItemSubType.Potion = "Potion"
end
