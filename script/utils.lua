function tableContains(table, value)
    for i = 1, #table do
        if (table[i] == value) then
            return true
        end
    end
    
    return false
end

function string.insert(str1, str2, pos)
    return str1:sub(1, pos) .. str2 .. str1:sub(pos + 1)
end

--  do the Fisher-Yates shuffle!
function scramble(a)
    for i = 1, #a - 1 do
        local j = random(i, #a)

        local temp = a[i]
        a[i] = a[j]
        a[j] = temp
    end
end

