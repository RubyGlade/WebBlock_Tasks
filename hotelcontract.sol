pragma solidity ^0.8.7;

contract hotelbooking{

    address payable public owner;
    
    // creating a struct for a hotel room
    struct HotelRoom{
        uint id;
        string name;
        uint price;
        string status;
    }

    // creating a mapping 
    mapping (uint => HotelRoom) public rooms;
    
    uint public roomsCount;

    function Hotel () public {
        owner = msg.sender();

        addRoom("Room 1");
        addRoom("Room 2");
        addRoom("Room 3");
        }

        function addRoom(string _name) private {
            roomsCount++;
            rooms[roomsCount] = HotelRoom(roomsCount, _name, 1 ether, "Not Booked");
        }

        event Occupy(address _customer, uint _price);

        function bookRoom (uint _id) payable public {
            require (_id > 0 && _id < roomsCount);
            require (compareStrings(rooms[_id].status, "Not Booked"));
            
            if (msg.value != 1000000000000000000);
                revert();
            owner.transfer(msg.value);
            rooms[_id].status = "Booked";
            emit Occupy(msg.sender,msg.value);
        }

        function compareStrings(string a, string b) public view returns (bool) {
            return keccak256(a) == keccak256(b);
        }
}