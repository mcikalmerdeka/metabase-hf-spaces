FROM metabase/metabase:latest

# Expose the internal container port
EXPOSE 3000

# Boot Metabase
CMD ["/app/run_metabase.sh"]
