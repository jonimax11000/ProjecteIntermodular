import { Request, Response, NextFunction } from "express";
import jwt from "jsonwebtoken";
import process from "process";
import { readFileSync } from "fs";

export const jwtMiddleware = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  let token = req.headers.authorization?.split(" ")[1];

  if (!token) {
    return res.status(401).json({ message: "Unauthorized: No token provided" });
  }

  const publicKeyPath = process.env.JWT_PUBLIC_KEY_PATH;
  if (!publicKeyPath) {
    console.error("JWT_PUBLIC_KEY_PATH is not defined");
    return res.status(500).json({ message: "Internal Server Error" });
  }

  let publicKey: Buffer;
  try {
    publicKey = readFileSync(publicKeyPath);
  } catch (err) {
    console.error("Could not read public key", err);
    return res.status(500).json({ message: "Internal Server Error" });
  }

  try {
    const decoded = jwt.verify(token, publicKey);
    req.body = req.body || {};
    req.body.decoded = decoded;
    next();
  } catch (error: any) {
    if (error.name === "TokenExpiredError") {
      console.log("Token expired. Attempting refresh...");
      const refreshToken = req.headers["refresh-token"] as any;
      if (!refreshToken) {
        console.log("No refresh token provided");
        return res.status(401).json({
          message: "Unauthorized: Token expired and no refresh token",
        });
      }

      const decodedExpired = jwt.decode(token) as any;
      if (!decodedExpired || !decodedExpired.uid || !decodedExpired.user_id) {
        console.log("Could not decode expired token to get UID");
        return res
          .status(401)
          .json({ message: "Unauthorized: Invalid token format" });
      }
      const uid = decodedExpired.uid;
      let id = decodedExpired.user_id;
      id = id.toString();

      try {
        const odooUrl = "http://odoo:8069/api/update/access-token";

        const response = await fetch(odooUrl, {
          method: "POST",
          headers: {
            Authorization: `Bearer ${token}`,
            "Content-Type": "application/json",
            refreshToken: refreshToken,
          },
          body: JSON.stringify({
            jsonrpc: "2.0",
            method: "call",
            id: id,
            params: {
              uid: uid,
            },
          }),
        });

        if (!response.ok) {
          console.log("Odoo refresh call failed with status:", response.status);
          return res
            .status(401)
            .json({ message: "Unauthorized: Refresh failed" });
        }

        const data: any = await response.json();

        const result = data.result || data;

        if (result.error) {
          console.log("Odoo returned error:", result.error);
          return res
            .status(401)
            .json({ message: "Unauthorized: Refresh denied" });
        }

        if (result.token) {
          const newToken = result.token;
          // Prepare new request state
          req.headers.authorization = `Bearer ${newToken}`;

          // Verify the NEW token just to set req.body.decoded correctly
          const newDecoded = jwt.verify(newToken, publicKey);
          req.body = req.body || {};
          req.body.decoded = newDecoded;

          // Send new token to client via header so they can update their storage
          res.setHeader("x-new-token", newToken);
          if (result.refreshToken) {
            res.setHeader("x-new-refresh-token", result.refreshToken); // If rotation happens
          }

          console.log("Refreshed token successfully for UID:", uid);
          next();
          return;
        } else {
          console.log("Odoo response did not contain token");
          return res
            .status(401)
            .json({ message: "Unauthorized: No token in refresh response" });
        }
      } catch (refreshErr) {
        console.error("Error during refresh call:", refreshErr);
        return res
          .status(401)
          .json({ message: "Unauthorized: Error refreshing token" });
      }
    } else {
      console.log("Token verification error: " + error.message);
      return res.status(401).json({ message: "Unauthorized" });
    }
  }
};

export const jwtMiddlewareAdmin = (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  const role = req.body.decoded.role;
  if (!role) {
    return res.status(401).json({ message: "Unauthorized" });
  }
  try {
    if (role !== "admin") {
      return res.status(401).json({ message: "Unauthorized" });
    }
    next();
  } catch (error) {
    return res.status(401).json({ message: "Unauthorized" });
  }
};

export const jwtMiddlewareUser = (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  const role = req.body.decoded.role;
  const active = req.body.decoded.active;
  const subscription_level = req.body.decoded.subscription_level;
  const level = req.path;
  const paths = level.split("/");
  const nivel = paths[1];
  if (!role) {
    return res.status(401).json({ message: "Unauthorized" });
  }
  try {
    if (
      (role == "user" || role == "admin") &&
      active &&
      subscription_level >= nivel
    ) {
      next();
    } else {
      return res.status(401).json({ message: "Unauthorized" });
    }
  } catch (error) {
    return res.status(401).json({ message: "Unauthorized" });
  }
};
