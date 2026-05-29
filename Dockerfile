FROM metabase/metabase:latest

# The official Metabase image already has ENTRYPOINT ["/app/run_metabase.sh"] configured.
# Do NOT add a CMD here — it would be passed as an argument to the entrypoint script,
# causing Metabase to interpret it as an unrecognized CLI command.
EXPOSE 3000
