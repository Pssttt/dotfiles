function f --wraps='cd $(fd --type directory | fzf)' --description 'alias f=cd $(fd --type directory | fzf)'
  cd $(fd --type directory | fzf) $argv
        
end
