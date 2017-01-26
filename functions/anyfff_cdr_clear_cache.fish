function anyfff_cdr_force_clear_caches -d 'remove all cd histories'
  find $ANYFFF__CDR_CACHE_PATH -type f \
    ! -name $ANYFFF__CDR_HISTORIES_FILE \
    | xargs rm -f ^/dev/null
end
