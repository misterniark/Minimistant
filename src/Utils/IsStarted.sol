// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


abstract contract IsStarted {
    bool private _started;
    event CityStarted(bool start);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _started = false;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyIfStarted() {
        _checkStart();
        _;
    }
    modifier onlyIfNotStarted{
        _checkNotStart();
        _;
    }
    /**
     * @dev Returns the address of the current owner.
     */
    function _start() internal virtual {
         _started = true;
        emit CityStarted(_started);
    }
    function started() public view returns (bool) {
        return _started;
    }
    
    function _checkStart() internal view virtual {
        require(_started == true, "NOTSTARTED");
    }
    function _checkNotStart() internal view virtual {
        require(_started == false, "ALREDYSTARTED");
    }
}