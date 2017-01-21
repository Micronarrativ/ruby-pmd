# Bash completion file for pdfmd
# copy to /etc/bash_completion.d to use it
_pdfmd()
{
  local cur prev opts tags chapter
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"
  chapter="${COMP_WORDS[1]}"
  tags='all author keywords title subject createdate'

  # The basic options
  opts="edit clean config init rename show sort stat --version --revision"

  #
  # complete the arguments to some of the basic commands
  #
  case "${chapter}" in
    init)
      case "${prev}" in
        -r|--remove) # Remove 
          local parameter='bash_completion'
          COMPREPLY=( $(compgen -W "${parameter}" -- ${cur}) )
          return 0
          ;;
        *)
          local parameter='--remove bash_completion'
          COMPREPLY=( $(compgen -W "${parameter}" -- ${cur}) )
          return 0
          ;;
      esac
      ;;
    edit)
      case "${prev}" in
        -t|--tags) # Define the tags
          local tags='all author keywords title subject createdate'
          COMPREPLY=( $(compgen -W "${tags}" -- ${cur}) )
          return 0
          ;;
        -r|--rename) # Rename files
          local files=$(ls *.pdf)
          COMPREPLY=( $(compgen -W "${files}" -- ${cur}) )
          return 0
          ;;
        -o|--opendoc) # Open the document
          local files=$(ls *.pdf)
          COMPREPLY=( $(compgen -W "${files}" -- ${cur}) )
          return 0
          ;;
        'all') # all tags
          local files="$(find . -maxdepth 1 -type f -iname '*.pdf')"
          COMPREPLY=( $(compgen -W "${files}" -- ${cur}) )
          return 0
          ;;
        *)
          local tags="--tags --rename --opendoc $(find . -maxdepth 1 -type f -iname '*.pdf')"
          COMPREPLY=( $(compgen -W "${tags}" -- ${cur}) )
          return 0
          ;;
      esac

      ;;
    clean) # Clean some stuff
      case "${prev}" in
        -t|--tags)
          local tags='all author keywords title subject createdate'
          COMPREPLY=( $(compgen -W "${tags}" -- ${cur}) )
          return 0
          ;;
        all|author|keywords|title|subject|createdate)
          local parameter="$(ls *.pdf)"
          COMPREPLY=( $(compgen -W "${parameter}") )
          return 0
          ;;
        
        *)
          local parameter="--tags $(find . -maxdepth 1 -type f -iname '*.pdf')"
          COMPREPLY=( $(compgen -W "${parameter}") )
          return 0
          ;;
      esac
      ;;
    config) # Config pdfmd
      case "${prev}" in
        edit|clean|rename|sort|stat)
          local parameter=''
          COMPREPLY=( $(compgen -W "${parameter}") )
          return 0
          ;;
        *)
          local parameter="clean edit rename sort stat"
          COMPREPLY=( $(compgen -W "${parameter}") )
          return 0
          ;;
      esac
      ;;
    rename) # Rename files
      case "${prev}" in
        -k|--nrkeywords)
          local parameter="3"
          COMPREPLY=( $(compgen -W "${parameter}" -- ${cur}) )
          return 0
          ;;
        -o|--outputdir)
          return 0
          ;;
        *)
          local parameter="--dryrun --allkeywords --nrkeywords --outputdir --copy $(ls *.pdf)"
          COMPREPLY=( $(compgen -W "${parameter}" -- ${cur}) )
          return 0
          ;;
      esac
      ;;
    show) # Show status of files

      case "${prev}" in
        -t|--tags)
          COMPREPLY=( $(compgen -W "${tags}" -- ${cur}) )
          return 0
          ;;
        -i|--includepdf)
          local files=$(find . -maxdepth 1 -type f -iname '*.pdf')
          COMPREPLY=( $(compgen -W "${files}" -- ${cur}) )
          return 0
          ;;
        -f|--format)
          local format='hash json yaml csv'
          COMPREPLY=( $(compgen -W "${format}" -- ${cur}) )
          return 0
          ;;
        all|author|keywords|title|subject|createdate)
          local files=$(ls *.pdf)
          COMPREPLY=( $(compgen -W "${files}" -- ${cur}) )
          return 0
          ;;
        *)
          local parameter="--tags --format $(find . -maxdepth 1 -type f -iname '*.pdf')"
          COMPREPLY=( $(compgen -W "${parameter}" -- ${cur}) )
          return 0
          ;;
      esac
      ;;
    sort) # Sorting files
      case "$prev" in
        -d|--destination)
          local directories="$(find . -maxdepth 1 -type d)"
          COMPREPLY=( $(compgen -W "${directories}" -- ${cur} ) )
          return 0
          ;;
        *)
          local parameter="--destination --copy --overwrite --dryrun --interactive --typo $(find . -maxdepth 1 -type f -iname '*.pdf')" 
          COMPREPLY=( $(compgen -W "${parameter}" -- ${cur}) )
          return 0
          ;;
      esac
      
      # Default output
      local parameter="--destination --copy --overwrite --dryrun --typo $(find . -maxdepth 1 -type f -iname '*.pdf')"
      COMPREPLY=( $(compgen -W "${parameter}" -- ${cur}) )
      return 0

      ;;
    stat)

      case "${prev}" in
        -r|--recursive)
          local parameter="$(find . -maxdepth 1 -type d)"
          COMPREPLY=( $(compgen -W "${parameter}" -- ${cur}) )
          return 0
          ;;
        -t|--tags)
          local tags='all author keywords title subject createdate'
          COMPREPLY=( $(compgen -W "${tags}" -- ${cur}) )
          return 0
          ;;
        *)
          local parameter="--recursive --tags $(find . -maxdepth 1 -type d)"
          COMPREPLY=( $(compgen -W "${parameter}" -- ${cur}) )
          return 0
          ;;
      esac

      # Default output
      local parameter="-t -ri $(find . -maxdepth 1 -type d)"
      COMPREPLY=( $(compgen -W "${parameter}" -- ${cur}) )
      return 0
      ;;
    *)
      ;;
  esac

  COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
}
complete -o default -F _pdfmd pdfmd
