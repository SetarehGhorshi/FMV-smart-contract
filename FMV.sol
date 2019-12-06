pragma solidity ^0.5.1;
////////////////////////////////////////////////////////////////////////////// database contract
contract FMVkeeper{
    mapping(address=>VideoContracts) Videos;
    constructor()public{
     k=0;   
    }
    
    mapping(uint256=> bytes32) allHashes;
    mapping(uint256=> bytes32) allPHashes;
    mapping(uint256=> address) allContracts;
    uint256 public k;
    
   struct VideoContracts {
   address vid_owner;
   address parent;
   bool original;
   bytes32 hash;
   bytes32 perceptualH;
 }
 ///////////////////////////////// this function only works when called from video contracts
    function addVideoChild(address contract_address,address parent_owner_address,address second_owner, bytes32 VideoHash,bytes32 perceptualH) external {
        require(Videos[msg.sender].vid_owner==parent_owner_address);
        Videos[contract_address]=VideoContracts({vid_owner:second_owner,parent:msg.sender,hash:VideoHash,original:false,perceptualH:perceptualH});
        allHashes[k]=VideoHash;
        allPHashes[k]=perceptualH;
        allContracts[k]=contract_address;
        k=k+1;
    }
 ////////////////////////////////// adding an original video
    function addVideo(bytes32 hash, address contract_address,bytes32 perceptualH) external returns(bool){
    bool newVid = true;
    for(uint256 i = 0 ; i < k ; i++){
        if (allHashes[i]==hash){
            newVid=false;
            break;
        }
    bytes32 xor = allPHashes[i]^perceptualH;
    uint256 HammingDist=0;
    for(uint8 j=0; j<32;j++){
        if(getBit(xor,j)==true){
        HammingDist += 1;}
    }
    require(HammingDist>=3);
    }
    if(newVid == true){
     Videos[contract_address]=VideoContracts({vid_owner:msg.sender,parent:address(0),hash:hash,original:true,perceptualH:perceptualH});
     allHashes[k]=hash;
     allContracts[k]=contract_address;
     allPHashes[k]=perceptualH;
     k=k+1;
     return true;}
     else{
     return false;
     }
    }
 ///////////////////////////////////
    function getBit(bytes32 a, uint8 n) private returns (bool) {
        return a & shiftLeft(0x01, n) != 0;
    }
    function shiftLeft(bytes1 a, uint8 n) private returns (bytes1) {
        uint8 shifted = uint8(a) * 2 ** n;
        return bytes1(shifted);
    }
  ///////////////////////////////// check if your video is valid
    function checkValidity(bytes32 hash, bytes32 perceptualH) external returns(bool, address){
    bool valid = false;
    address videoContractAddress;
    uint256 minDist=1000;
    uint256 minIdx=0;
    for(uint256 i = 0 ; i < k ; i++){
        if (allHashes[i]==hash){
            valid=true;
            videoContractAddress=allContracts[i];
            break;
        }
    bytes32 xor = allPHashes[i]^perceptualH;
    uint256 HammingDist=0;
    for(uint8 j=0; j<32;j++){
        if(getBit(xor,j)==true){
        HammingDist += 1;}
    }
     if(HammingDist<minDist){minDist = HammingDist;
       minIdx=i;  
     }   
    }
    
    if(valid == true){
        return(true,videoContractAddress);
    }
    if(minDist<3){
        return (false,allContracts[minIdx]);
    }
    else{
        return(false,address(0));
    }
    }
    
}
///////////////////////////////////////////////////////////////////////////////////////// video contract
contract Videos {
  address public parent;
  bool public original;
  address public owner;//Ethereum address of the video owner
  string public info;//informtation about the video
  bytes32 public IPFS_Hash;//IPFS hash of the uploaded video on the IPFS server
  string public metadata;
  uint256 public timestamp;
  uint256 numberOfEditReqs=0;
  struct editRequests{
     address artist ;
     bytes32 hash;
     string metadata;
     uint256 timestamp;
     bool editPermission;
     
  }
  struct finalPermssion{
      bool accepted;
      bytes32 perceptualH;
      address artist;
  }
  mapping(address=>finalPermssion) public finalPermssionReqs;
  
  constructor(address  parent_input,bool  original_input,string memory info_input,bytes32  IPFS_Hash_input,string memory metadata_input,uint256 timestamp_input) public{
    parent=parent_input;  
    original=original_input;
    info=info_input;
    IPFS_Hash=IPFS_Hash_input;
    metadata=metadata_input;
    timestamp=timestamp_input;
    owner=msg.sender;
  }
  mapping(uint256=>editRequests) public editReq;
  
  ////////////////////////////////////
  modifier onlyOwner(address user) {
         require(user == owner );  
        _;
    }
  ///////////////////////////////////// ask the owner to edit their video
  function editRequest(bytes32 vid_hash, string calldata vid_metadata) external{
   editReq[numberOfEditReqs]=editRequests({artist:msg.sender,hash:vid_hash,metadata:vid_metadata,timestamp:now,editPermission:false});
  } 
  //////////////////////////////////// owner accepts the edit request by id
function acceptReq(uint256 id) external onlyOwner(msg.sender){
    editReq[id].editPermission = true;
}
/////////////////////////////////////// ask for final permission after creating your video's smart contract 
function finalPermssionReq(address contract_address,bytes32 hash,bytes32 perceptualH) external returns(bool){
    uint256 userId;
 for(uint256 i = 0 ; i < numberOfEditReqs; i++){
     if(editReq[i].hash==hash){
         userId=i;
         break;
     }
    
     
 }
  require(msg.sender==editReq[userId].artist);
     require(editReq[userId].editPermission==true);
     finalPermssionReqs[contract_address].accepted=false;
     finalPermssionReqs[contract_address].perceptualH=perceptualH;
     finalPermssionReqs[contract_address].artist=msg.sender;
     return true;
}
///////////////////////////////////////owner can accept the smart contracts after checking them and add them to the database
function addChild(address contract_address, bytes32 hash)external onlyOwner(msg.sender){
    finalPermssionReqs[contract_address].accepted=true;
    FMVkeeper fmvkeeper = FMVkeeper(0x692a70D2e424a56D2C6C27aA97D1a86395877b3A);
                                    
    fmvkeeper.addVideoChild(contract_address,msg.sender,finalPermssionReqs[contract_address].artist,hash,finalPermssionReqs[contract_address].perceptualH);
}
/////////////////////////////////////////
function getOwner()external returns(address){
    return owner;
}
}
