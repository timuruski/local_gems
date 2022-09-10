case $1 in
  --init)
    # 1. Symlink Gemfile -> Gemfile.local
    if [[ ! -L Gemfile.local ]]
    then
      ln -s Gemfile Gemfile.local
    fi

    # 2. Add Gemfile.local.lock" to .gitignore
    if [[ ! -f ".gitignore" ]] || ! grep -q "Gemfile.local.lock" .gitignore
    then
      echo "Gemfile.local.lock" >> .gitignore
    fi

    # 3. Add local_gems? method to Gemfile.
    if ! grep -q "def local_gems\?" Gemfile
    then
      echo """
Add this definition to your Gemfile, to check when configuring gems:

def local_gems?
  File.basename(__FILE__) == "Gemfile.local"
end
"""
    fi
    ;;

  --enable)
    bundle config --local gemfile Gemfile.local
    ;;

  --disable)
    bundle config unset --local gemfile
    ;;

  --reset)
    rm Gemfile.local.lock
    ;;

  "")
    bundle config gemfile
    ;;
esac
