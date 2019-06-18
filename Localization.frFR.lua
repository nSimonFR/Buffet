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
end
