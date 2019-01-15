## Regenerating liblouis files

When moving to a newer version of Liblouisutdml, you may want to
update the liblouis files:

- Possibly edit the `filter_liblouis_files.sh` script.
- Generate the files:
  ```sh
  mvn process-sources -Pgenerate-liblouis-files
  ```
- Move the generated files to the `src` directory and check them in:
  ```sh
  mvn process-sources -Pgenerate-liblouis-files
  mv target/generated-resources/lbu_files/* src/main/resources/lbu_files/
  ```
