#!
for d in */
        do
          cd $d
          echo $d
                for f in $(find ./ -maxdepth 1 -type f -exec grep -l 'Options in use' {} \;)
                 do 
                        mv $f outfile.txt
                 done
          cd ..
        done