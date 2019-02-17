pragma solidity ^0.5.0;

import "../node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "../node_modules/openzeppelin-solidity/contracts/lifecycle/Pausable.sol";

/// @title ETHdenver 2019 Project: GeoHunter
/// @dev Contract Project will inherit the contracts Ownable and Pausable from the OpenZeppelin libarary
/// @dev Pausable is a circuit breaker which blocks all contract functions expect withdrawl by the owner 
contract GeoHunter is Ownable, Pausable {

    // Global variables
    uint32 public totalTags;
    uint32 public totalUsers;
    uint32 public totalScans;
    
    // Events
    event balanceNowUpdated(uint256 _newBalance);
    event tagNowRegistered(uint32 _tagIndex, string _tagUid, string _ipfsHash, string _lat, string _long);
    event userNowRegistered(string _userDid, string _username);
    event tagNowScanned(string userDid, string username, string tagUid, uint timestamp);

    // Structs & Mappings
    struct Tag {
        string Uid;
        string ipfsHash; // Could be a hash of a picture of the tag location 
        string lat;
        string long;
    }
    mapping (string => uint32) private tagIndex; // 0 returned means tag UID is unregistered
    mapping (uint32 => Tag) public tagList; // Since index 0 means tag UID is unregistered, index 1 to 5 will be the five game tags

    struct User {
        string userDid;
        string username;
        uint8 progress;
        uint startTime;
        uint endTime;
    }
    mapping (string => uint32) private userIndex; // 0 returned means user DID is unregistered
    mapping (uint32 => User) public userList; // Since index 0 means user DID is unregistered, 1st user is index 1

    struct Scan {
        string userDid;
        string username;
        string tagUid;
        uint timestamp;
    }
    mapping (uint32 => Scan) public scanList;

    /// @dev Constructor
    /// @dev Initialize totals, and hardcode game with the details of 5 tags
    constructor() public {
        totalTags = 0;
        totalUsers = 0;
        totalScans = 0;

        //  Hardcoded details for Tag index 1 (tag UID, IPFS hash, and location latitude and longitude)
        tagIndex["16199909d0b5fd"] = 1; // Replace with actual UID
        tagList[1].Uid = "16199909d0b5fd"; // Replace with actual UID
        tagList[1].ipfsHash = "1mWWQSuPMS6aXCbZKpEjPHPUZN2NjB3YrhJTHsV4X3vb2t";
        tagList[1].lat = "";
        tagList[1].long = "";

        //  Hardcoded details for Tag index 2 (tag UID, IPFS hash, and location latitude and longitude)
        tagIndex["26199909d0b5fd"] = 2; // Replace with actual UID
        tagList[2].Uid = "26199909d0b5fd"; // Replace with actual UID
        tagList[2].ipfsHash = "2mWWQSuPMS6aXCbZKpEjPHPUZN2NjB3YrhJTHsV4X3vb2t"; // Replace with actual IPFS hash
        tagList[2].lat = "";
        tagList[2].long = "";

        //  Hardcoded details for Tag index 3 (tag UID, IPFS hash, and location latitude and longitude)
        tagIndex["36199909d0b5fd"] = 3; // Replace with actual UID
        tagList[3].Uid = "36199909d0b5fd"; // Replace with actual UID
        tagList[3].ipfsHash = "3mWWQSuPMS6aXCbZKpEjPHPUZN2NjB3YrhJTHsV4X3vb2t"; // Replace with actual IPFS hash
        tagList[3].lat = "";
        tagList[3].long = "";

        //  Hardcoded details for Tag index 4 (tag UID, IPFS hash, and location latitude and longitude)
        tagIndex["46199909d0b5fd"] = 4; // Replace with actual UID
        tagList[4].Uid = "46199909d0b5fd"; // Replace with actual UID
        tagList[4].ipfsHash = "4mWWQSuPMS6aXCbZKpEjPHPUZN2NjB3YrhJTHsV4X3vb2t"; // Replace with actual IPFS hash
        tagList[4].lat = "";
        tagList[4].long = "";

        //  Hardcoded details for Tag index 5 (tag UID, IPFS hash, and location latitude and longitude)
        tagIndex["56199909d0b5fd"] = 5; // Replace with actual UID
        tagList[5].Uid = "56199909d0b5fd"; // Replace with actual UID
        tagList[5].ipfsHash = "5mWWQSuPMS6aXCbZKpEjPHPUZN2NjB3YrhJTHsV4X3vb2t"; // Replace with actual IPFS hash
        tagList[5].lat = "";
        tagList[5].long = "";
    }

    /// @dev Fallback function
    function () external payable {
    } 

    /// @dev The owner can add ETH to the contract when the contract is not paused
    function addBalance() public payable 
        onlyOwner
        whenNotPaused {
        emit balanceNowUpdated(address(this).balance);   
    }

    /// @dev The owner can withdraw ETH from the contract when the contract is not paused
    /// @param amount Value to be withdrawn in wei
    function withdrawBalance (uint256 amount) public 
        onlyOwner
        whenNotPaused {
        msg.sender.transfer(amount);
        emit balanceNowUpdated(address(this).balance);  
    }

    /// @dev Register tags with a particular index number and IPFS hash 
    /// @param _tagIndex Desired Tag Index - will overwrite previous tag registered to that index if existing 
    /// @param _tagUid Tag UID code 
    /// @param _ipfsHash IPFS hash associated with the tag (could be a hash of a picture of the tag location)
    /// @param _lat Location (latitude) of tag
    /// @param _long Location (longitude) of tag
    function registerTag(
        uint32 _tagIndex,
        string memory _tagUid,
        string memory _ipfsHash,
        string memory _lat,
        string memory _long) 
        public
        onlyOwner
        returns (bool)
        {
        require(_tagIndex > 0, "Tag index cannot be 0 (reserved for unregistered tags)");
        if (tagIndex[_tagUid] == 0) {
            tagIndex[_tagUid] = _tagIndex;
            totalTags++;
        }
        tagList[_tagIndex].Uid = _tagUid;
        tagList[_tagIndex].ipfsHash = _ipfsHash;
        tagList[_tagIndex].lat = _lat;
        tagList[_tagIndex].long = _long;

        emit tagNowRegistered(_tagIndex, _tagUid, _ipfsHash, _lat, _long);
        return true;
    }

    /// @dev Register users with a unique index number and associated username
    /// @param _userDid User's uPort DID code
    /// @param _username User's Uport username
    function registerUser(string memory _userDid, string memory _username) public returns (bool) {
        require(userIndex[_userDid] == 0, "User already registered");
        totalUsers++;
        userIndex[_userDid] = totalUsers;
        
        userList[userIndex[_userDid]].userDid = _userDid;
        userList[userIndex[_userDid]].username = _username;
        userList[userIndex[_userDid]].progress = 0;
        userList[userIndex[_userDid]].startTime = 0;
        userList[userIndex[_userDid]].endTime = 0;

        emit userNowRegistered(_userDid, _username);
        return true;
    }

    /// @dev Record the scanning of tags 
    /// @param _userDid User's uPort DID code
    /// @param _username User's uPort username
    /// @param _tagUid Tag UID code 
    function scanTag(string memory _userDid, string memory _username, string memory _tagUid) public returns (bool) {
        if (userIndex[_userDid] == 0) {
            require(registerUser(_userDid, _username), "User already registered"); // Register user if not already registered
        }

        string memory nextTagUid = tagList[userList[userIndex[_userDid]].progress + 1].Uid;
        if (keccak256(abi.encode(_tagUid)) == keccak256(abi.encode(nextTagUid))) {
            userList[userIndex[_userDid]].progress++; // Progress user if they have scanned the next tag
            if (userList[userIndex[_userDid]].progress == 1) {
                userList[userIndex[_userDid]].startTime == block.timestamp; // If tag is index 1 then record user's start time
            }
            if (userList[userIndex[_userDid]].progress == 5) {
                userList[userIndex[_userDid]].endTime == block.timestamp; // If tag is index 5 then record user's end time
            }
        }

        totalScans++;

        scanList[totalScans].userDid = _userDid;
        scanList[totalScans].username = _username;
        scanList[totalScans].tagUid = _tagUid;
        scanList[totalScans].timestamp = block.timestamp;

        emit tagNowScanned(_userDid, _username, _tagUid, block.timestamp);
        return true;
    }

    /// @dev Get the index and Uid for the next tag the user requires 
    /// @param _userDid User's uPort DID code
    /// @param _nextTagIndex The index number for the next tag the user requires (1 to 5; 6 means user is done)
    /// @param _nextTagUid Tag UID code for the next tag the user requires
    function nextTagRequired(string memory _userDid) public view returns (uint32 _nextTagIndex, string memory _nextTagUid, bool _success) {
        require(userIndex[_userDid] > 0, "User not registered");
        _nextTagIndex = userList[userIndex[_userDid]].progress + 1;
        _nextTagUid = tagList[_nextTagIndex].Uid;
        _success = true;
    }

    /// @dev Returns the current total number of tags registered
    /// @param _totalTags Current total number of tags registered
    function getTotalTags() public view returns (uint32 _totalTags) {
        _totalTags = totalTags;
    }

    /// @dev Returns the current total number of users registered
    /// @param _totalUsers Current total number of users registered
    function getTotalUsers() public view returns (uint32 _totalUsers) {
        _totalUsers = totalUsers;
    }

    /// @dev Returns the current total number of scans
    /// @param _totalScans Current total number of scans
    function getTotalScans() public view returns (uint32 _totalScans) {
        _totalScans = totalScans;
    }

}