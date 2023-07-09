echo "BUILDING DOCKER IMAGE"
sudo sh dockerized_stablediff/build.sh pull;
echo "======================================="

echo "GENERATING OPTIONS FOR IMAGES"
STR=$'siberian husky\ngerman shepherd\nchihuahua\nlabrador retriever\npug\npoodle';
echo "$STR" >> doglist.txt;
echo "======================================="

echo "GENERATING SINGLE SOURCE IMAGES"
while read p; do
    sudo sh dockerized_stablediff/build.sh run --model 'stabilityai/stable-diffusion-2-1' "$p";
done <doglist.txt
echo "======================================="

echo "GENERATING PERMUTATION SOURCE IMAGES"
parallel 'bash -c "[ {1} != {2} ] && echo {1} mixed with {2} dog"' :::: doglist.txt doglist.txt >> dogperms.txt;
while read p; do
    sudo sh dockerized_stablediff/build.sh run --model 'stabilityai/stable-diffusion-2-1' "$p";
done <dogperms.txt
echo "======================================="
echo "DONE"
