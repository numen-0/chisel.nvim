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
  + `dot.case`
  + `kebab-case`
  + `n12e`
  + `PascalCase`
  + `snake_case`
  + `UPPER_CASE`
  + `path/case`
  + `space case`
- Custom methods can be added.

## Install

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
    "numen-0/chisel.nvim",
    options = {},
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

```lua
local chisel = require("chisel")

chisel.register("double", function(str)
    return str .. str
end)

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

