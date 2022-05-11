// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.4;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface Token {
    function transferFrom(address, address, uint) external returns (bool);
    function transfer(address, uint) external returns (bool);
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}



library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    function transferOwnership(address newOwner) public virtual onlyOwner {
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

}

contract World_Step is Context, IERC20, Ownable {
    
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;
	mapping (address => mapping (address => uint256)) private _allowances;

	uint256 private _totalSupply = 1*10**9*10*9;
	uint256 private _maxSupply = 1*10**9*10**9;

    mapping (address => bool) private _isExcludedFromFee;

    uint256 private _tFeeTotal;
    
    uint256 private _taxFeeOnBuy = 4;
    
    uint256 private _taxFeeOnSell = 1;
    
    uint256 private _taxFee;

    bool private _activePair = false;
    
    string private constant _name = "World Step";
    string private constant _symbol = "WSP";
    uint8 private constant _decimals = 9;
    
    address payable private _developmentAddress = payable(0x8492cbd894686D7e98214541903c7BA6f94928D6);
    address payable private _marketingAddress = payable(0xa4eD7aa4eF5deB0A63e97d9Cb77445aE553feb1d);
    address payable private _rewardPool = payable(0xe061915592536656a92B9fd59e46b19eF920692F);


    IUniswapV2Router02 public uniswapV2Router;
    IUniswapV2Factory public uniswapV2Factory;

    address public _factory;
    address public uniswapV2Pair;
    
    constructor () {
        _balances[_msgSender()] = _totalSupply;
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(address(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3));
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH() );
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_developmentAddress] = true;
        _isExcludedFromFee[_marketingAddress] = true;
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    modifier onlyDev() {	
        require(owner() == _msgSender() || _developmentAddress == _msgSender(), "Caller is not the dev");	
        _;	
    }

    function name() public view returns (string memory) {
		return _name;
	}

	function symbol() public view returns (string memory) {
		return _symbol;
	}

	function decimals() public view returns (uint8) {
		return _decimals;
	}

	function totalSupply() public view override returns (uint256) {
		return _totalSupply;
	}
	
	function maxSupply() public view returns (uint256) {
		return _maxSupply;
	}

	function availableBalance(address account) public view returns (uint256) {
		return _balances[account];
	}

	function balanceOf(address account) public view override returns (uint256) {
		return _balances[account];
	}

	function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
		_transfer(_msgSender(), recipient, amount);
		return true;
	}

	function allowance(address owner, address spender) public view virtual override returns (uint256) {
		return _allowances[owner][spender];
	}

	function approve(address spender, uint256 amount) public virtual override returns (bool) {
		_approve(_msgSender(), spender, amount);
		return true;
	}

	function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
		_transfer(sender, recipient, amount);
		_approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
		return true;
	}

	function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
		_approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
		return true;
	}

	function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
		_approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
		return true;
	}

	function _transfer(address sender, address recipient, uint256 amount) internal virtual {
		require(sender != address(0), "ERC20: transfer from the zero address");
		require(recipient != address(0), "ERC20: transfer to the zero address");

		_beforeTokenTransfer(sender, amount);

		_balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
		_balances[recipient] = _balances[recipient].add(amount);
		emit Transfer(sender, recipient, amount);
	}
	function _burn(address account, uint256 amount) internal virtual {
		require(account != address(0), "ERC20: burn from the zero address");

		_beforeTokenTransfer(account, amount);

		_balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
		_totalSupply = _totalSupply.sub(amount);
		emit Transfer(account, address(0), amount);
	}

	function _approve(address owner, address spender, uint256 amount) internal virtual {
		require(owner != address(0), "ERC20: approve from the zero address");
		require(spender != address(0), "ERC20: approve to the zero address");

		_allowances[owner][spender] = amount;
		emit Approval(owner, spender, amount);
	}


	function _beforeTokenTransfer(address from, uint256 amount) internal virtual {
		require(_balances[from] >= amount, "ERC20: transfer amount exceeds balance");
	}

    // function _buyToken(address from, address to,uint256 amount) public { 
    //     require(from != address(0), "ERC20: transfer from the zero address");
    //     require(to != address(0), "ERC20: transfer to the zero address");
    //     require(amount > 0, "Transfer amount must be greater than zero");

    //     _taxFee = 0;

    //     if(from == owner() || to == owner() ) { 
    //         uint256 ownerTokenBalance = balanceOf(address(owner()));
    //         if(ownerTokenBalance >  0) { 
    //             _tokenTransfer(from, to, amount);
    //         }
    //     }

    // }

    // function _Safetransfer(address sender, address recipient, uint256 amount) internal virtual {
	// 	require(sender != address(0), "ERC20: transfer from the zero address");
	// 	require(recipient != address(0), "ERC20: transfer to the zero address");
    //     _tokenTransfer(sender,recipient,amount);
	//     emit Transfer(sender, recipient, amount);
	// }

    // function _transfer(address from, address to, uint256 amount) private {
    //     require(from != address(0), "ERC20: transfer from the zero address");
    //     require(to != address(0), "ERC20: transfer to the zero address");
    //     require(amount > 0, "Transfer amount must be greater than zero");
        
    //     if (from != owner() && to != owner()) {
    //         uint256 ownerTokenBalance = balanceOf(address(owner()));
    //         if (!inSwap && from != uniswapV2Pair && swapEnabled && ownerTokenBalance > 0) {
    //             swapTokensForEth(ownerTokenBalance);
    //             uint256 contractETHBalance = address(this).balance;
    //             if(contractETHBalance > 0) {
    //                 sendETHToFee(address(this).balance);
    //             }
    //         }
            
    //         if(from == uniswapV2Pair && to != address(uniswapV2Router)) {
    //             _redisFee = _redisFeeOnBuy;
    //             _taxFee = _taxFeeOnBuy;
    //         }
    
    //         if (to == uniswapV2Pair && from != address(uniswapV2Router)) {
    //             _redisFee = _redisFeeOnSell;
    //             _taxFee = _taxFeeOnSell;
    //         }
            
    //         if ((_isExcludedFromFee[from] || _isExcludedFromFee[to]) || (from != uniswapV2Pair && to != uniswapV2Pair)) {
    //             _redisFee = 0;
    //             _taxFee = 0;
    //         }
            
    //     }

    //     _tokenTransfer(from,to,amount);
    // }

    
    // function _tokenTransfer(address sender, address recipient, uint256 amount) private {
    //     _transferStandard(sender, recipient, amount);
    // }

    event devAddressUpdated(address indexed previous, address indexed adr);
    
    function setNewDevAddress(address payable dev) public onlyDev() {
        emit devAddressUpdated(_developmentAddress, dev);	
        _developmentAddress = dev;
        _isExcludedFromFee[_developmentAddress] = true;
    }
    
    event marketingAddressUpdated(address indexed previous, address indexed adr);
    function setNewMarketingAddress(address payable markt) public onlyDev() {
        emit marketingAddressUpdated(_marketingAddress, markt);	
        _marketingAddress = markt;
        _isExcludedFromFee[_marketingAddress] = true;
    }

    // function _transferStandard(address sender, address recipient, uint256 tAmount) private {
    //     (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tTeam) = _getValues(tAmount);
    //     _rOwned[sender] = _rOwned[sender].sub(rAmount);
    //     _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount); 
    //     _takeTeam(tTeam);
    //     _reflectFee(rFee, tFee);
    //     emit Transfer(sender, recipient, tTransferAmount);
    // }

    function setFee(uint256 redisFeeOnBuy, uint256 redisFeeOnSell, uint256 taxFeeOnBuy, uint256 taxFeeOnSell) public onlyDev {
	    require(redisFeeOnBuy < 11, "Redis cannot be more than 10.");
	    require(redisFeeOnSell < 11, "Redis cannot be more than 10.");
	    require(taxFeeOnBuy < 7, "Tax cannot be more than 6.");
	    require(taxFeeOnSell < 7, "Tax cannot be more than 6.");
        _taxFeeOnBuy = taxFeeOnBuy;
        _taxFeeOnSell = taxFeeOnSell;
    }

    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFee[accounts[i]] = excluded;
        }
    }
}