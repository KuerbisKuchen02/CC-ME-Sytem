if not fs.exists(".db/containers") then
    local containers = {
        reserved = {},
        input = {},
        output = {},
        crafting = {},
        meta = {
            count_bulk = 0,
            count_mixed = 0,
            count_input = 0,
            count_output = 0,
            count_crafting = 0
        }
    }
end