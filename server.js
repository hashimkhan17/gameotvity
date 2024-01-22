const express = require('express');
const ethers = require('ethers');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

const app = express();
const port = 3000;

// Define storage before using it in multer

let currentTokenId = 0; // Initialize the currentTokenId
const tokenImageMap = {};
// Define storage before using it in multer
const storage = multer.diskStorage({
    destination: function (req, file, cb) {
      cb(null, 'uploads/');
    },
    filename: function (req, file, cb) {
      currentTokenId += 1;
      const tokenId = currentTokenId.toString();
      const originalExtension = path.extname(file.originalname);
  
      // Ensure the original extension is valid or use a default extension
      const extension = (originalExtension !== '') ? originalExtension : '.png';
  
      cb(null, tokenId + extension);
  
      // Save the mapping of token ID to image filename
      tokenImageMap[tokenId] = tokenId + extension;
    }
  });

const upload = multer({ storage: storage });  // Use storage after it's defined

const SIGNING_DOMAIN_NAME = "Voucher-Domain";
const SIGNING_DOMAIN_VERSION = "1";
const chainId = 5;
const contractAddress = "0xF1b52De4a5DbF32D3322d4EaE357F85a49252f00";
const contractabi = require("./abi.json");
const ALCHEMY_API_KEY = 'cyA-yTv8vgRXyLKn7ylGNSQzY0X3LOf_';
const alchemyUrl = `https://eth-goerli.alchemyapi.io/v2/${ALCHEMY_API_KEY}`;

const provider = new ethers.providers.JsonRpcProvider(alchemyUrl);
const privateKey = "9d241954b3bd3fe02337a657dc8e0c7cede159b8ab67b5382f746b05a7324b5d"; 

const wallet = new ethers.Wallet(privateKey, provider);

const domain = {
  name: SIGNING_DOMAIN_NAME,
  version: SIGNING_DOMAIN_VERSION,
  verifyingContract: contractAddress,
  chainId,
};

// Maintain a mapping of token IDs to image filenames


async function createVoucher(tokenId, amount, buyer) {
    const voucher = { tokenId, amount, buyer };
    const types = {
      LazyNFTVoucher: [
        { name: "tokenId", type: "uint256" },
        { name: "amount", type: "uint256" },
        { name: "buyer", type: "address" },
      ],
    };

    const signature = await wallet._signTypedData(domain, types, voucher);

    return {
        ...voucher,
        signature
    };
}

async function sendTransaction(voucher) {
    const contract = new ethers.Contract(
        contractAddress,
        contractabi,
        wallet
    );

    const tx = await contract.NFTmint(voucher, {
        gasPrice: ethers.utils.parseUnits('10', 'gwei'),
        value: ethers.utils.parseEther('0.01'), 
        
    }
    );


    await tx.wait();
    console.log('Transaction Hash:', tx.hash);
}

app.get('/run', async (req, res) => {
    try {
        const voucher = await createVoucher(2, 15, "0x4C25a5E840Be6797D8ae394A72bBc60bABa254e9");
        console.log(`[${voucher.tokenId}, ${voucher.amount}, "${voucher.buyer}", "${voucher.signature}"]`);

        await sendTransaction(voucher);
        res.send('Transaction sent successfully!');
    } catch (error) {
        console.error('Error:', error.message);
        res.status(500).send('Internal Server Error');
    }
});

app.use(express.static(path.join(__dirname, 'public')));

app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'index.html'));
});

app.get('/tokens/:id', (req, res) => {
    const tokenId = req.params.id;

    // Check if the token ID is in the mapping
    if (tokenImageMap.hasOwnProperty(tokenId)) {
        const filename = tokenImageMap[tokenId];
        const imagePath = path.join(__dirname, 'uploads', filename);

        // Check if the file exists
        if (fileExists(imagePath)) {
            res.sendFile(imagePath, (err) => {
                if (err) {
                    console.error('Error sending file:', err);
                    res.status(500).send('Internal Server Error');
                }
            });
        } else {
            res.status(404).send('Image not found.');
        }
    } else {
        res.status(404).send('Token not found.');
    }
});

// Function to check if a file exists
function fileExists(filePath) {
    try {
        return fs.statSync(filePath).isFile();
    } catch (err) {
        return false;
    }
}

app.post('/upload', upload.single('image'), (req, resp) => {
    if (req.file) {
      
      resp.send(`Image successfully uploaded for NFT with ID`);
    } else {
      resp.status(400).send('Error uploading image.');
    }
  });
  
app.listen(port, () => {
    console.log(`Server is running at http://localhost:${port}`);
});
