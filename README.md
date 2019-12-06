# FMV-smart-contract
This smart contract keeps videos from attacks and helps checking the validity of the edited videos. 
# Database Contract
Keeps the list of all registered videos and helps people to check any video they find to know whether or not it is valid.

- Use the `addVideo` function to add an original video to the database. If the video you try to add is similar to any previously added video, the smart contract recognizes you and does not add your video to the list. 

- Use the `checkValidity` function to check the validity of a video you see by its hashes. If the video was previously added to the database, it gives you the contract address of that video so you can check the parents and find the original video. If the video is not among the list, it either gives you the most similar video contract address or the zero address which shows that the video is unreiable.


