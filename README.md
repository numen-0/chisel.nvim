# chisel.nvim

```
                                                         .-----.                
                                                       .'    .'.`-.             
                                                     .'    .'\`   .|            
                                                   .'    .'\`   .!!|            
                                                 .'    .'\`   .!!!!|            
                                               .'    .'\`   .!!!!!'             
                                             .'    .'\`   .!!!!!'               
                                           .'    .'\`   .!!!!!'                 
                                         .-----.'\`   .!!!!!'                   
                                       .'    .'\`-. .!!!!!'                     
                                      .----.'\`   .|!!!!'                       
                                     !      `-. .!!|!!'                         
                                     |         |!!!|'                           
                                     ! .---.   |!!'                             
                                 ,.--''  .:'   |!'                              
                               .'        :----'                                 
                             .'          :                                      
                           .'          ,:'                                      
                         .'          ,:'                                        
                       .'          ,:'                                          
                     .'          ,:'                                            
                   .'          ,:'                                              
                 .'          ,:'                                                
               .'          ,:'                                                  
             .'          ,:'                                                    
            .--.       ,:'                                                      
           /    `-----:'                                                        
          '-.        /'                                                         
             `------'                                                           
```

Simple, stupid case converter for Neovim.

Transform the current word or a visual selection between multiple naming
conventions.

## Features

- Convert the **current word**
- Convert the **visual selection**. Works with selections that span multiple
  lines or mixed separators.
- Built-in case conversions:
  + `camelCase`
  + `comma,case`
  + `dot.case`
  + `kebab-case`
  + `n12e`
  + `path/case`
  + `PascalCase`
  + `Phrase_case`
  + `snake_case`
  + `space case`
  + `Title_Case`
  + `UPPER_CASE`
  + `Train-Case`
- Custom methods can be added.

## Install

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
    "numen-0/chisel.nvim",
    opts = {},
}
```

## Configuaration

```lua
require("chisel").setup({
    methods = {
        -- add custom case converters here (or/and override existing ones)
        shout = function(str)
            return str:upper() .. "!"
        end,
    },
})
```

## Create your own case transformations

Simple example:

```lua
local chisel = require("chisel")

chisel.register("double", function(str)
    return str .. str
end)
```

Another example using `chisel.method` utils:

```lua
local chisel  = require("chisel")
local methods = require("chisel.methods")

chisel.register("Capita.Dot", methods.generic("cap", nil, "."))
```

A more complex example:

```lua
local chisel = require("chisel")
local utils = require("chisel.utils")

-- hibrid_camelCase
chisel.register("hibrid", function(str)
    local p = utils.parts(str)
    if #p == 0 then return "" end

    -- head is first word lowercase
    local head = utils.lower(p[1])

    -- tail is the rest as camelCase
    local tail = table.concat(vim.list_slice(p, 2, #p), "_")

    -- join
    if tail then
        tail = chisel.apply("camel", tail)
        return head .. "_" .. tail
    else
        return head
    end
end)
```

Keymaps:

```lua
local chisel = require("chisel")

vim.keymap.set("n", "<leader>cd", function()
    chisel.current_word("double")
end, { desc = "Duplicate the text (normal mode)" })

vim.keymap.set("v", "<leader>cd", function()
    chisel.visual("double")
end, { desc = "Duplicate the text (visual mode)" })
```

## API

| function                 | description                                       |
|:------------------------:|:--------------------------------------------------|
| `register(name, func)`   | Register a case transformation (`func: (string) -> string`) |
| `apply(method, txt)`     | Transform the string, return transformed string or original if method is unknown |
| `current_word(method)`   | Apply the word under the cursor                   |
| `visual(method)`         | Apply to the current visual selection             |

### Command

```vim
" current word
:Chisel <method>

" words in range
:'<,'>Chisel <method>
```

- Works on the current word by default
- If a range/visual selection is provided, it will transform the selection

## License

All the repo falls under the [MIT License](/LICENSE).

