# ugc-script

### A script for updating the no-follow and no-index fields on user generated recipes

This script loops through the `GF-User-recipes-to-keep.csv` file, and checks each entry to see if it is in there.

If it is, it will set no-follow/no-index to be false, else it will set it as true

If the PUT request fails, it will store the ID of the failure to the `putFailures.csv` file to be ran through at a later date

When the script is ran it will ask for a starting page number, a limit and a bearer token

