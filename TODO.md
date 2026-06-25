Get changes from home server because i did some changes there. The new setup involves iwctl and networking.interfaces module.

Add MagicDNS name servers configuration for tailscale in all hosts.

Explain to me about sops and secrets and why should we use that, if there is any better alternatives or options in other case and later understand how its configured because there are some secrets like ssh keys lying around the code and this reopsitory is on github yk.

After making sure we identified how we are going to organize secrets, we need to start organazing them and also seeing if we are leaking any secrets (git story also) or importing other peoples (old repository owner) secrets with us.

Once that is sorted out, commit everything, send them the server and rebuild

Start git repository for the config in the server as well

Start working on the arr apps.
