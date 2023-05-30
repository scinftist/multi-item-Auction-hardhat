// SPDX-License-Identifier: MIT
// Double Linked List
// Created by sciNFTist.eth

pragma solidity ^0.8.0;

library DoubleLinkedLibrary {
    struct DList {
        uint256 nextPointer;
        uint256 head;
        uint256 tail;
        uint256 len;
        uint256 lastIndex; //new
        bool finished;
        // uint
        mapping(uint256 => node) nodes;
        mapping(uint256 => uint256) nodeIndex; //new
    }
    struct node {
        uint256 data;
        address bidder;
        uint256 prev;
        uint256 next;
    }

    // modifier notFinished(DList storage DL) {
    //     require(!DL.notFinished, "finished");
    //     _;
    // }
    // event

    function init0(DList storage DL) internal {
        unchecked {
            // uint256 end = uint256(0) - 1;
            uint256 end = type(uint256).max;
            DL.nodes[1] = node(end, address(0), 0, 0);
        }
        DL.head = 1;
        DL.tail = 1;
        DL.len = 0;
        DL.nextPointer = 2;
        DL.lastIndex = 1;

        // nodes[end] = node(0,0,)
    }

    function setSort(
        DList storage DL,
        uint256 _pos,
        uint256 data,
        address bidder
    ) internal {
        setAfterMid(DL, _pos, data, bidder);
    }

    function posValidator(
        DList storage DL,
        uint256 _pos,
        uint256 data
    ) internal view returns (bool) {
        node memory _node = DL.nodes[_pos];
        uint256 ppos = _node.next;
        node memory next_node = DL.nodes[ppos];
        if (_node.data >= data) {
            if (data >= next_node.data) {
                // if()
                return true;
            }
        }
        return false;
    }

    function findPos(DList storage DL, uint256 data)
        internal
        view
        returns (uint256)
    {
        uint256 pos = DL.head;
        // if (data > nodes[head].data) {
        //     return 0;
        // }
        for (uint256 i = 0; i < DL.len + 1; i++) {
            if (posValidator(DL, pos, data)) {
                return pos;
            }
            pos = DL.nodes[pos].next;
        }
    }

    function index0(DList storage DL, uint256 pos) internal {
        require(DL.finished, "n");
        require(DL.nodeIndex[pos] == 0); //if indexed return index?
        require(getPrev(DL, pos) != 0);
        uint256 posNext = getNext(DL, pos);
        // uint256 starting = getHead(DL);
        uint256 starting = DL.lastIndex;
        uint256 next;
        // uint256 lastIndex;
        // uint256 lastIndexedPos;
        next = getNext(DL, starting);
        for (;;) {
            DL.nodeIndex[next] = DL.nodeIndex[starting] + 1;
            starting = next;
            next = getNext(DL, starting);
            if (next == 0 || next == posNext) {
                DL.lastIndex = pos;
                break;
            }
        }
        //return DL.nodeIndex[pos];?
    }

    function index(DList storage DL, uint256 pos) internal {
        require(DL.nodeIndex[pos] == 0);
        require(getPrev(DL, pos) != 0);
        uint256 starting = pos;
        uint256 lastIndex;
        uint256 lastIndexedPos;
        for (;;) {
            lastIndexedPos = getPrev(DL, starting);
            lastIndex = getIndex(DL, lastIndexedPos);
            if (lastIndex != 0 || lastIndexedPos == 1) {
                break;
            } else {
                starting = lastIndexedPos;
            }
        }
        uint256 nextPos;
        for (;;) {
            nextPos = getNext(DL, lastIndexedPos);
            indexThePos(DL, nextPos);
            if (nextPos == pos) {
                break;
            }
        }
    }

    function indexThePos(DList storage DL, uint256 pos) internal {
        require(DL.nodeIndex[pos] == 0);
        require(pos > 1, "not in list");
        uint256 _prev = getPrev(DL, pos);
        if (_prev == 1) {
            DL.nodeIndex[pos] = 1;
        }
        uint256 prev_Index = DL.nodeIndex[_prev];
        if (DL.nodeIndex[_prev] != 0) {
            DL.nodeIndex[pos] = prev_Index + 1;
        }
    }

    function getIndex(DList storage DL, uint256 pos)
        internal
        view
        returns (uint256)
    {
        return DL.nodeIndex[pos];
    }

    function finish(DList storage DL) internal {
        DL.finished = true;
    }

    function isFinished(DList storage DL) internal view returns (bool) {
        return DL.finished;
    }

    function getCounter(DList storage DL) internal view returns (uint256) {
        return DL.nextPointer;
    }

    function getData(DList storage DL, uint256 pos)
        internal
        view
        returns (uint256)
    {
        return DL.nodes[pos].data;
    }

    function getBidder(DList storage DL, uint256 pos)
        internal
        view
        returns (address)
    {
        return DL.nodes[pos].bidder;
    }

    function getPrev(DList storage DL, uint256 pos)
        internal
        view
        returns (uint256)
    {
        return DL.nodes[pos].prev;
    }

    function getNext(DList storage DL, uint256 pos)
        internal
        view
        returns (uint256)
    {
        return DL.nodes[pos].next;
    }

    function getLen(DList storage DL) internal view returns (uint256) {
        return DL.len;
    }

    function getHead(DList storage DL) internal view returns (uint256) {
        return DL.head;
    }

    function getTail(DList storage DL) internal view returns (uint256) {
        return DL.tail;
    }

    function setAfterMid(
        DList storage DL,
        uint256 _pos,
        uint256 data,
        address bidder
    ) private {
        node memory _node = DL.nodes[_pos];
        require(!DL.finished, "it's finished");
        // les than this
        require(_node.data >= data, "bad sort");
        //biger than next

        // node memory next_node = nodes[_node.next];
        require(data >= DL.nodes[_node.next].data, "bad sort 2");
        // if (nodes[_node.next].next == 0) {
        //     emit farRight(nextPointer);
        // }

        DL.nodes[DL.nextPointer] = node(data, bidder, _pos, _node.next);
        // if (_node.next != 0) {
        //     nodes[_node.next].prev = nextPointer;
        // }
        if (_pos == DL.tail) {
            DL.tail = DL.nextPointer;
        } else {
            DL.nodes[_node.next].prev = DL.nextPointer;
        }
        DL.nodes[_pos].next = DL.nextPointer;
        DL.nextPointer++;
        DL.len++;
        // if (_pos == tail) {
        //     tail = nextPointer;
        // }
    }

    function removeThis(DList storage DL, uint256 _pos) internal {
        require(!DL.finished, "it's finished");
        node memory _node = DL.nodes[_pos];
        require(_node.prev != 0, "not in array");
        DL.nodes[_node.prev].next = _node.next;
        DL.nodes[_node.next].prev = _node.prev;
        //
        if (_pos == DL.tail) {
            DL.tail = _node.prev;
        }
        delete DL.nodes[_pos];
        DL.len--;
    }
}
