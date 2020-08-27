pragma solidity ^0.4.24;

contract Airline {
    
    address public owner;

    struct Customer {
        uint loyaltyPoints;
        uint totalFlights;
    }

    struct Flight {
        string name;
        uint price;
    }

    uint etherPerPoint = 0.5 ether;
    
    Flight[] public flights;//Vuelos que hay disponibles
    
    mapping(address => Customer	) public customers; //Los clientes
    mapping(address =>	Flight[]) public customerFlights; //Vuelos de cada cliente
    mapping(address =>	uint) public customerTotalFlights; //Numero de vuelos totales de cada cliente

    event FlightPurchased(address indexed customer, uint price);

    constructor() public {
        owner = msg.sender;
        flights.push(Flight('Tokio', 4 ether));
        flights.push(Flight('Paris', 1 ether)); 
        flights.push(Flight('Madrid', 2 ether));  
    }

    modifier isOwner {
        require(msg.sender == owner);
        _;
    }

    function buyFlight(uint flightIndex) public payable {
        Flight memory flight = flights[flightIndex];
        require(msg.value == flight.price);

        Customer storage customer = customers[msg.sender];
        customer.loyaltyPoints += 5;
        customer.totalFlights += 1;
        customerFlights[msg.sender].push(flight); //Se añade el vuelo a la lista de vuelos de cada customer
        customerTotalFlights[msg.sender] ++;

        emit FlightPurchased(msg.sender, flight.price);
    }

    function totalFlights() public view returns(uint) {
        return flights.length;
    }

    function redeemLoyaltyPoints() public {
        Customer storage customer = customers[msg.sender];
        uint etherToRefound = etherPerPoint * customer.loyaltyPoints;
        msg.sender.transfer(etherToRefound);
        customer.loyaltyPoints = 0;
    }

    function getRefundableEther() public view returns(uint) {
        Customer storage customer = customers[msg.sender];
        uint etherToRefound = etherPerPoint * customer.loyaltyPoints;
        return etherToRefound;
    }

    function getAirlineBalance() public view isOwner returns(uint) {
        address airlineAddress = this;
        return airlineAddress.balance;
    }


}