-- Companion: Model presets shown in the Models tab of the options.
--
-- To add a model, add one line to the table below:
--     { name = "Name shown on the button", id = <creature display ID> },
-- Display IDs can be found on wowhead (an NPC's "Model" / display ID) or tried with
-- the Custom Display ID box in the Models tab. Order here = order in the list.

local _, ns = ...

ns.modelPresets = {
    { name = "Tyrande Whisperwind",   id = 7274 },
    { name = "Lady Anacondra",        id = 4313 },
    { name = "Inquisitor Whitemaine", id = 2043 },
}
