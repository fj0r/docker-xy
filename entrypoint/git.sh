if [[ -n "$git_pull" ]]; then
bash <<- EOF &
    sudo mkdir -p /var/log/git_pull/
    for dir in \$(echo \$git_pull| tr "," "\n"); do
        cd \$dir
        echo "git pull in \$dir"
        git pull 2>&1 | sudo tee -a /var/log/git_pull/\$(basename \$dir) > /dev/null &
    done
EOF
fi
