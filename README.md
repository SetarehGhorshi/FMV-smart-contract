# FMV-smart-contract
This smart contract keeps videos from attacks and helps checking the validity of the edited videos. 
Please note that all videos must be uploaded on [IPFS](https://ipfs.io/) and their hash must be used here. We also need the perceptual hash of the videos. 
- More info about perceptual hashing :
https://www.phash.org/
# FMVkeeper Contract (Database Contract)
Keeps the list of all registered videos and helps people to check any video they find to know whether or not it is valid.

- Use the `addVideo` function to add an original video to the database. If the video you try to add is similar to any previously added video, the smart contract recognizes you and does not add your video to the list. 

- Use the `checkValidity` function to check the validity of a video you see by its hashes. If the video was previously added to the database, it gives you the contract address of that video so you can check the parents and find the original video. If the video is not among the list, it either gives you the most similar video contract address or the zero address which shows that the video is unreiable.

# Video Contract 

An artist can make a smart contract for her/his original video and then add it to the database, or he/she can send an edit request to the original video contract to be able to add the new edited video to the database.

- Use `editRequest` to request the original artist to edit her/his video.

- Use `acceptReq` to accept a request if you are the owner of the smart contract.

- Use `finalPermssionReq` after your request has been accepted in order to ask for the final permission and give the address of your video contract to the original order to be added to the database.

- Use `addChild` if you are the ower of smart contract to accept the waiting smart contracts to be added to the database and tell the database contract to add them.
