---Trim the start and the end of the string from the chars
---@param str string The string that is going to get trimmed
---@param substrs string[] An array of all character sequences that we will trim off
local function trim_str(str, substrs)
    -- logic:
    -- start looping over the string from the start
    -- keep an index, increment until the current char is not part of the chars to trim
    -- starts looping over the string, but backwards
    -- keep an index, decrement repeatedly until the current char is not part of the chars to trim
    -- get the substring with the two indices

    local i = 1
    local j = #str

    while true do
        local ch = string.sub(str, i, i)

        local trim_char = false
        for _, val in ipairs(substrs) do
            if ch == val then
                trim_char = true
                break
            end
        end

        -- if we shouldn't trim this char, that means we have found the start of the main word. We want to stop here
        if trim_char == false then
            break
        end
        i = i + 1
    end


    while true do
        local ch = string.sub(str, j, j)

        local trim_char = false
        for _, val in ipairs(substrs) do
            if ch == val then
                trim_char = true
                break
            end
        end



        -- if we shouldn't trim this char, that means we have found the start of the main word. We want to stop here
        if trim_char == false then
            break
        end
        j = j - 1
    end

    return string.sub(str, i, j)
end

return { trim_str = trim_str }
