local Waves_T = {}

export type WaveConfig = {
    _MAX_NPC: number,
    _TIME: number,
}

Waves_T.Wave_1 = {
    _MAX_NPC = 10,
    _TIME = 1,
}

Waves_T.Wave_2 = {
    _MAX_NPC = 15,
    _TIME = 1,
}

return Waves_T
