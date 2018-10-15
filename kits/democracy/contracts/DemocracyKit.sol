pragma solidity 0.4.24;

import "@aragon/kits-beta-base/contracts/BetaKitBase.sol";


contract DemocracyKit is BetaKitBase {
    constructor(
        DAOFactory _fac,
        ENS _ens,
        MiniMeTokenFactory _minimeFac,
        IFIFSResolvingRegistrar _aragonID,
        bytes32[4] _appIds
    )
        BetaKitBase(_fac, _ens, _minimeFac, _aragonID, _appIds)
        public
    {}

    function newToken(string name, string symbol) external returns (MiniMeToken token) {
        token = minimeFac.createCloneToken(
            MiniMeToken(address(0)),
            0,
            name,
            18,
            symbol,
            true
        );
        cacheToken(token, msg.sender);
    }

    function newInstance(
        string name,
        address[] holders,
        uint256[] tokens,
        uint256 supportNeeded,
        uint256 minAcceptanceQuorum,
        uint64 voteDuration
    )
        external
    {
        MiniMeToken token = popTokenCache(msg.sender);
        Kernel dao;
        ACL acl;
        Voting voting;
        (dao, acl, , , , voting) = createDAO(
            name,
            token,
            holders,
            tokens,
            uint256(-1)
        );

        voting.initialize(
            token,
            supportNeeded,
            minAcceptanceQuorum,
            voteDuration
        );

        // create vote permission
        acl.createPermission(acl.ANY_ENTITY(), voting, voting.CREATE_VOTES_ROLE(), voting);

        // burn support modification permission
        acl.createBurnedPermission(voting, voting.MODIFY_SUPPORT_ROLE());

        cleanupPermission(acl, voting, acl, acl.CREATE_PERMISSIONS_ROLE());
    }
}